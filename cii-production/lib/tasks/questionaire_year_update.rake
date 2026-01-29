require 'roo'
require 'json'
require 'axlsx'

namespace :questionaire_year_update do
  desc "Update year questionnaire data from spreadsheet"

  task load_questionaire_year_update_data: :environment do
    last_id = QuestionnaireVersion.maximum(:id)
    questionnaire_version_id = last_id.to_i
    questionnaire_new_version_id = last_id.to_i + 1
    file_path = "lib/QuestionnaireVersion#{questionnaire_version_id}.xlsx"
    replace_file_path = "lib/QuestionnaireVersion#{questionnaire_new_version_id}.xlsx"
    excel = Roo::Spreadsheet.open(file_path)
    # Get the current year
    current_year = Date.today.year

    workbook = Axlsx::Package.new

    labels_to_modify = [
      ["FY #{current_year - 1}", "FY #{current_year}"],
      ["FY #{current_year - 2}", "FY #{current_year - 1}"],
      ["FY #{current_year - 3}", "FY #{current_year - 2}"]
    ]

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

    def valid_json?(string)
      begin
        JSON.parse(string)
        return true
      rescue JSON::ParserError => e
        return false
      end
    end

    # Modify each sheet
    excel.each_with_pagename do |sheet_name, sheet|
      axlsx_sheet = workbook.workbook.add_worksheet(name: sheet_name)

      sheet.each_with_index do |row, row_index|
        modified_row = []

        row.each_with_index do |cell, column_index|
          if column_index == 3 and valid_json?(cell.to_s.strip)
            begin
              parsed_json = JSON.parse(cell.to_s.strip)
              labels_to_modify.each do |old_label, new_label|
                modify_json(parsed_json, "label", old_label, new_label)
              end
              modified_row << parsed_json.to_json
            rescue JSON::ParserError => e
              puts "Error parsing JSON in row #{sheet_name} #{row_index + 1}, column #{column_index + 1}: #{e.message}"
              modified_row << cell
            end
          else
            modified_row << cell
          end
        end

        axlsx_sheet.add_row(modified_row)
      end
    end

    workbook.serialize(replace_file_path)

    excel.close

    puts "Modified Excel file saved to '#{replace_file_path}'"
  end
end
