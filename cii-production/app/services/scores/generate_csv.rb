module Scores
  class GenerateCsv < ApplicationService
    def self.perform company_user_id, data_type
      if data_type == "cii_user"
        category_score = CategoryScore.where(company_user_id: company_user_id)
        questionnaire_score = QuestionnaireScore.where(company_user_id: company_user_id)
        s_no1 = 0
        header1 = ["S.No", "Aspect Name", "Score"]
        CSV.generate do |csv|
          csv << ['','CII Scorecard Report','']
          csv << header1
          category_score.each do |category|
            csv << [
              s_no1 += 1,
              ApplicationRecord::ASPECT_TYPE[category.category_type.to_sym],
              (category.score).round(2)
            ]
          end
          csv << []
          csv << []

        end

      elsif data_type == "company_user"
        category_score = CategoryScore.where(company_user_id: company_user_id.to_i)
              s_no = 0
              headers = ["S.No", "Aspect Name", "Score"]
              CSV.generate do |csv|
                csv << ['','CII Scorecard Report''']
                csv << headers
                category_score.each do |category|
                  csv << [
                    s_no += 1,
                    ApplicationRecord::ASPECT_TYPE[category.category_type.to_sym],
                    (category.score).round(2)
                  ]
                end
              end
      end
    end

  end
end