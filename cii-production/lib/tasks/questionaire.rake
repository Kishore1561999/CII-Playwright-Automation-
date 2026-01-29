require "roo"

namespace :questionaire do
  desc "Import questionnaire data from spreadsheet"

  task load_questionaire_data: :environment do
    
    #Questionnaire.delete_all
    last_id = QuestionnaireVersion.maximum(:id)
    questionnaire_version_id = last_id.to_i + 1
    file_path = "lib/QuestionnaireVersion#{questionnaire_version_id}.xlsx"
    unless  File.exist?(file_path)
      file_path = "lib/QuestionnaireVersion#{last_id}.xlsx"
    end

    data = Roo::Spreadsheet.open(file_path)
    QuestionnaireVersion.create(versionname: 'Version'+ " " + questionnaire_version_id.to_s)
    ActiveRecord::Base.connection.reset_pk_sequence!("questionnaires")

    ["Corporate Governance", "Business Ethics", "Risk Management", "Transparency & Disclosure", "Human Rights", "Human Capital", "Occupational Health & Safety", "CSR", "Environmental Management", "Supply Chain", "Biodiversity", "Product Responsbility"].each_with_index do |sheet_name, sheet_idx|
      category_id = Category.find_by(category_name: sheet_name)&.id

      data.sheet(sheet_name).each_with_index do |row, idx|
        next if idx == 0
        Questionnaire.create!(question_id: row[0], question_name: row[1], question_type: row[2], options: JSON.parse(row[3]), category_id: category_id, questionnaire_version_id: questionnaire_version_id)
      end
    end
  end
end
