require 'sidekiq-scheduler'
require 'roo'
require 'axlsx'
require 'json'

class PeerbenchmarkYearUpdateJob
  include Sidekiq::Worker
  include ApplicationHelper
  sidekiq_options queue: :default
  
    def perform(*args)        
        # Dynamically build year modification hash
        current_year = Time.now.year
        year_modification = {}
        (2000..current_year).each do |year|
            year_modification[year] = year + 1
        end
        
        # File paths
        last_version = PeerBenchmarkingQuestionnaire.maximum(:version)
        questionnaire_version_id = last_version.to_i
        input_file = "lib/PeerBenchMarkingQuestionnaire#{questionnaire_version_id}.xlsx"
        output_file = "lib/PeerBenchMarkingQuestionnaire#{current_year}.xlsx"
        if current_year != last_version
            # Load the Excel file
            workbook = Roo::Excelx.new(input_file)
            
                # Prepare to write the modified data
                Axlsx::Package.new do |package|
                    workbook.sheets.each do |sheet_name|
                        sheet = workbook.sheet(sheet_name)
                
                        # Add a new sheet to the output workbook
                        package.workbook.add_worksheet(name: sheet_name) do |output_sheet|
                        sheet.each_with_index do |row, row_index|
                            modified_row = row.map.with_index do |cell, col_index|
                                if col_index == 3 && valid_json?(cell) # Assuming column index 3 contains JSON
                                    begin
                                        json_data = JSON.parse(cell)
                                        modify_json(json_data, year_modification)
                                        JSON.generate(json_data)
                                    rescue StandardError => e
                                        puts "Error modifying JSON at row #{row_index + 1}, column #{col_index + 1}: #{e.message}"
                                        cell
                                    end
                                else
                                    cell
                                end
                            end
                            output_sheet.add_row(modified_row)
                        end
                    end
                end        
                # Save the modified Excel file
                package.serialize(output_file)
            end        
            puts "Modified Excel file saved as #{output_file}"
            PeerBenchmarkingQuestionnaire.where(version: current_year).delete_all
            file_path = "lib/PeerBenchMarkingQuestionnaire#{current_year}.xlsx"
            data = Roo::Spreadsheet.open(file_path)
            ["Peer Benchmarking"].each_with_index do |sheet_name, sheet_idx|

                data.sheet(sheet_name).each_with_index do |row, idx|
                    next if idx == 0
                    PeerBenchmarkingQuestionnaire.create!(question_id: row[0], question_name: row[1], question_type: row[2], options: JSON.parse(row[3]), version: current_year )
                end
            end
        end
    end

    def valid_json?(json_str)
        begin
            JSON.parse(json_str)
            true
        rescue JSON::ParserError
            false
        end
    end

    def modify_json(data, year_modification)
        if data.is_a?(Hash)
            data.each do |key, value|
                if key == 'label' && value.match?(/\b\d{4}\b/)
                    year = value.to_i
                    if year_modification.key?(year)
                        data[key] = year_modification[year].to_s
                    end
                elsif value.is_a?(Hash) || value.is_a?(Array)
                    modify_json(value, year_modification)
                end
            end
        elsif data.is_a?(Array)
            data.each do |item|
                modify_json(item, year_modification)
            end
        end
    end

end

