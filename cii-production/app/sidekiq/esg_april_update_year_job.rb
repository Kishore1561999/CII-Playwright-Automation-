require 'roo'
require 'json'
require 'axlsx'

class EsgAprilUpdateYearJob
    include Sidekiq::Job

    def perform(*args)
        last_id = QuestionnaireVersion.maximum(:id)
        questionnaire_version_id = last_id.to_i
        questionnaire_new_version_id = last_id.to_i + 1
        file_path = "lib/QuestionnaireVersion#{questionnaire_version_id}.xlsx"
        replace_file_path = "lib/QuestionnaireVersion#{questionnaire_new_version_id}.xlsx"

        begin
            excel = Roo::Spreadsheet.open(file_path)
        rescue => e
            puts "Error opening file: #{e.message}"
            return
        end

        workbook = Axlsx::Package.new
        # current_year = Time.now.year
        current_year = 2026

        labels_to_modify = [
            ["FY #{current_year - 2}", "FY #{current_year - 1}"],
            ["FY #{current_year - 3}", "FY #{current_year - 2}"],
            ["FY #{current_year - 4}", "FY #{current_year - 3}"]
        ]

        excel.each_with_pagename do |sheet_name, sheet|
            axlsx_sheet = workbook.workbook.add_worksheet(name: sheet_name)

            sheet.each_with_index do |row, row_index|
                modified_row = process_row(row, sheet_name, row_index, labels_to_modify)
                axlsx_sheet.add_row(modified_row)
            end
        end

        workbook.serialize(replace_file_path)
        excel.close

        puts "Modified Excel file saved to '#{replace_file_path}'"
        
        # Load the updated data into the database
        load_questionnaire_data(questionnaire_new_version_id)
    end

    private

    def process_row(row, sheet_name, row_index, labels_to_modify)
        row.each_with_index.map do |cell, column_index|
            if column_index == 3
                modify_json_cell(cell, sheet_name, row_index, labels_to_modify)
            else
                cell
            end
        end
    end

    def modify_json_cell(cell, sheet_name, row_index, labels_to_modify)
        begin
            parsed_json = JSON.parse(cell.to_s.strip)
            labels_to_modify.each do |old_label, new_label|
                modify_json(parsed_json, "label", old_label, new_label)
            end
            parsed_json.to_json
        rescue JSON::ParserError => e
            puts "Error parsing JSON in row #{sheet_name} #{row_index + 1}: #{e.message}"
            cell
        end
    end

    def modify_json(json_obj, key_to_search, value_to_search, new_value)
        case json_obj
        when Hash
            json_obj.each do |key, value|
                if key == key_to_search && value == value_to_search
                    json_obj[key] = new_value
                elsif value.is_a?(Hash) || value.is_a?(Array)
                    modify_json(value, key_to_search, value_to_search, new_value)
                end
            end
        when Array
            json_obj.each do |item|
                modify_json(item, key_to_search, value_to_search, new_value) if item.is_a?(Hash) || item.is_a?(Array)
            end
        end
    end

    def load_questionnaire_data(questionnaire_version_id)
        file_path = "lib/QuestionnaireVersion#{questionnaire_version_id}.xlsx"
        return unless File.exist?(file_path)

        data = Roo::Spreadsheet.open(file_path)
        QuestionnaireVersion.create(versionname: "Version #{questionnaire_version_id}")
        ActiveRecord::Base.connection.reset_pk_sequence!("questionnaires")

        category_names = ["Corporate Governance", "Business Ethics", "Risk Management", "Transparency & Disclosure", "Human Rights", "Human Capital", "Occupational Health & Safety", "CSR", "Environmental Management", "Supply Chain", "Biodiversity", "Product Responsbility"]

        category_names.each do |sheet_name|
            category_id = Category.find_by(category_name: sheet_name)&.id
            next unless category_id

            data.sheet(sheet_name).each_with_index do |row, idx|
                next if idx == 0
                
                Questionnaire.create!(
                    question_id: row[0], question_name: row[1], question_type: row[2],
                    options: JSON.parse(row[3]), category_id: category_id,
                    questionnaire_version_id: questionnaire_version_id
                )
            end
        end
    end
end