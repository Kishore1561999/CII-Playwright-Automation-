require "json"

namespace :answers do
  desc "Answers Table user_answers column data Alteration by sectors"

  task alter_user_answers_data: :environment do
    p "Answers Table user_answers column data Alteration Initiated..."
    begin
      aspects = %w[cg be rm td hr hc em sc bd pr ohs csr]
      Answer.all.each do |answer|
        answers = {}
        aspects.each do |aspect|
          aspect_answers = {}
          (answer.user_answers).each do |key, value|
            aspect_answers[key] = value if key.start_with?("#{aspect}_")
          end
          answers["#{aspect}_answers"] = aspect_answers
        end
        Answer.where(user_id: answer.user_id)
              .update(answer_type: ApplicationRecord::COMPANY_USER, cg_answers: answers['cg_answers'], be_answers: answers['be_answers'],
                      rm_answers: answers['rm_answers'], td_answers: answers['td_answers'], hr_answers: answers['hr_answers'],
                      hc_answers: answers['hc_answers'], em_answers: answers['em_answers'], sc_answers: answers['sc_answers'],
                      bd_answers: answers['bd_answers'], pr_answers: answers['pr_answers'], ohs_answers: answers['ohs_answers'],
                      csr_answers: answers['csr_answers'])
        Answer.create(user_id: answer.user_id, answer_type: ApplicationRecord::CII_USER, status: answer.status, user_answers: answer.user_answers,
                      submitted_at: answer.submitted_at, created_at: answer.created_at, updated_at: answer.updated_at,
                      cg_answers: answers['cg_answers'], be_answers: answers['be_answers'], csr_answers: answers['csr_answers'],
                      rm_answers: answers['rm_answers'], td_answers: answers['td_answers'], hr_answers: answers['hr_answers'],
                      hc_answers: answers['hc_answers'], em_answers: answers['em_answers'], sc_answers: answers['sc_answers'],
                      bd_answers: answers['bd_answers'], pr_answers: answers['pr_answers'], ohs_answers: answers['ohs_answers'])
      end
      p "Answer table data Successfully Altered..."
    rescue
      p "Answer table data alteration failed, Check the log file..."
    end
  end
end