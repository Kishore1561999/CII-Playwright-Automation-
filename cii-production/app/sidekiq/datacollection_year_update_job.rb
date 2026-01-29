require 'sidekiq-scheduler'
require 'roo'
require 'axlsx'
require 'json'

class DatacollectionYearUpdateJob
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
        last_version = DataCollectionQuestionnaire.maximum(:version)
        questionnaire_version_id = last_version.to_i
        input_file = "lib/DataCollectionQuestionnaire#{questionnaire_version_id}.xlsx"
        output_file = "lib/DataCollectionQuestionnaire#{current_year}.xlsx"
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
            DataCollectionQuestionnaire.where(version: current_year).delete_all
            file_path = "lib/DataCollectionQuestionnaire#{current_year}.xlsx"
            data = Roo::Spreadsheet.open(file_path)
            ["Data Collection"].each_with_index do |sheet_name, sheet_idx|

                data.sheet(sheet_name).each_with_index do |row, idx|
                    next if idx == 0
                    DataCollectionQuestionnaire.create!(question_id: row[0], question_name: row[1], question_type: row[2], options: JSON.parse(row[3]), version: current_year )
                end
            end

            @total_answers_data = DataCollectionCompanyDetail
                            .where(status: ApplicationRecord::WORK_SUBMITTED)
                            .joins("INNER JOIN data_collection_answers ON data_collection_company_details.id = data_collection_answers.company_id")
                            # .where(data_collection_answers: { version: current_year })
                            .where(data_collection_answers: { version: DataCollectionAnswer
                            .select('MAX(version)')
                            .group(:company_id)
                            .where('data_collection_answers.company_id = data_collection_company_details.id') })
                            .select("data_collection_answers.*")
            user_answers = @total_answers_data.map do |company_detail|
            {
                answers: company_detail.user_answers,
                version: company_detail.version,
                company_id: company_detail.company_id,
                company_sector: company_detail.sector,
                submitted_at: company_detail.submitted_at,
                company_name: company_detail.company_name,
                hidden_company_name: company_detail.hidden_company_name,
                status: company_detail.status  
            }
            end
            user_answers.each do |data|
                if data[:version] != current_year
                updated_data = interchange_table_data(data[:answers], [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
                updated_data = interchange_table_data(data[:answers], [16, 17, 18, 22, 23], same_row: false )
                data[:answers] = updated_data
                @data = DataCollectionAnswer.find_by(company_id: data[:company_id], version: current_year)
                if @data.nil?
                    DataCollectionAnswer.create(status: data[:status], company_id: data[:company_id], sector: data[:company_sector], user_answers: updated_data, submitted_at: data[:submitted_at], version:  current_year, company_name: data[:company_name], hidden_company_name: data[:hidden_company_name])
                end
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

    def interchange_table_data(data, table_ids, same_row: true)
        table_ids.each do |table_id|
          table_key_prefix = "pb_#{format('%02d', table_id)}_table"
          table_rows = data.select { |key, _| key.start_with?(table_key_prefix) }
                            .sort_by { |key, _| key.match(/row(\d+)/)[1].to_i }
                            .to_h
      
          shifted_rows = table_rows.values.rotate(-1)
          shifted_rows[0] = ""
          table_rows.each_with_index do |(key, _), index|
            match_first_row = key.match(/row\d+_number1/)
            match_third_row = key.match(/row\d+_number3/)
            if match_first_row || ( !same_row && match_third_row )
             data[key] = ""
            else
             data[key] = shifted_rows[index]
            end
          end
        end
    
         data
    end

end

