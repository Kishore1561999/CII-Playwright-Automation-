require "roo"

namespace :data_collection_questionnaire do
  desc "Import questionnaire data from spreadsheet"

  task load_data_collection_questionnaire_data: :environment do
    include ApplicationHelper
    
    DataCollectionQuestionnaire.where(version: current_year).delete_all
    file_path = "lib/DataCollectionQuestionnaire#{current_year}.xlsx"
    data = Roo::Spreadsheet.open(file_path)
    ["Data Collection"].each_with_index do |sheet_name, sheet_idx|

      data.sheet(sheet_name).each_with_index do |row, idx|
        next if idx == 0
        DataCollectionQuestionnaire.create!(question_id: row[0], question_name: row[1], question_type: row[2], options: JSON.parse(row[3]), version: current_year )
      end
    end
  end
end
