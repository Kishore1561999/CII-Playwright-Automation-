module Scores
  class GenerateScoreV1 < ApplicationService
    def initialize(company_user_id)
      @company_user_id = company_user_id
    end

    def perform
      cii_user_answers = Answer.find_by(user_id: @company_user_id, answer_type: ApplicationRecord::CII_USER)
      answers = Answers::AnswerService.aspects_answer_merger(cii_user_answers).with_indifferent_access

      categories = ApplicationRecord::CATEGORY_WISE_QUESTION_NO
      total_categories_count = ApplicationRecord::CATEGORY_WISE_QUESTION_NO.count
      non_countable_categories_count = 0
      total_categories_score = 0
      governance_aspect_score = 0
      environmental_aspect_score = 0
      social_aspect_score = 0
      governance_aspect_na_count = 0
      environmental_aspect_na_count = 0
      social_aspect_na_count = 0

      ActiveRecord::Base.transaction do
        categories.each do |category|
          category_name = category[0].split('_').first
          category_total_score = 0
          category_not_applicable_status = 0
          questions_count = category.count
          non_countable_questions_count = 0
          category.each do |question_code|
            local_score = 0
            question_not_applicable_status = 0
            case question_code.to_s
            when "hr_01", "csr_02", "em_04"
              non_countable_questions_count += 1
              question_not_applicable_status = 1
            when "cg_01"
              if answers[:cg_01] == "Information available"
                if answers[:cg_01_option1_number1].present? && answers[:cg_01_option1_number2].present? && answers[:cg_01_option1_number3].present?
                  cg_01_temp_score = ((answers[:cg_01_option1_number3].to_f + answers[:cg_01_option1_number2].to_f) / (answers[:cg_01_option1_number1].to_f + answers[:cg_01_option1_number2].to_f + answers[:cg_01_option1_number3].to_f)) * 100
                  case cg_01_temp_score
                  when 30..49.99
                    local_score = 50
                  when 50..75.99
                    local_score = 100
                  else
                    local_score = 0
                  end
                end
              elsif answers[:cg_01] == "Not applicable"
                if answers[:cg_01_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "cg_02"
              if answers[:cg_02].present?
                case answers[:cg_02]
                when "Chair is non-independent non-executive, but a lead independent chair is appointed"
                  local_score += 50
                when "Chair is Independent director"
                  local_score += 100
                when "Not applicable"
                  if answers[:cg_02_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                    non_countable_questions_count += 1
                    question_not_applicable_status = 1
                  end
                else
                  # type code here
                end
              end
            when "cg_03"
              if answers[:cg_03] == "Frequency of external evaluation of board performance"
                if answers[:cg_03_option1_radio].present?
                  case answers[:cg_03_option1_radio].to_s
                  when "Every year"
                    local_score += 100
                  when "Every 2/3 years"
                    local_score += 50
                  when "Ad-hoc"
                    local_score += 10
                  else
                    local_score = 0
                  end
                end
              elsif answers[:cg_03] == "Not applicable"
                if answers[:cg_03_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "cg_04"
              if answers[:cg_04] == "Information available"
                if answers[:cg_04_option1_checkbox1].present?
                  if answers[:cg_04_option11_number1].to_f >= 90
                    local_score += 50
                  elsif answers[:cg_04_option11_number1].to_f >= 75
                    local_score += 25
                  elsif answers[:cg_04_option11_number1].to_f >= 50
                    local_score += 10
                  end
                end
                if answers[:cg_04_option1_checkbox2].present? && answers[:cg_04_option12_radio].present?
                  case answers[:cg_04_option12_radio].to_s
                  when "Semi Annually"
                    local_score += 25
                  when "Quaterly"
                    local_score += 50
                  when "Annually"
                    local_score += 20
                  else
                    # type code here
                  end
                end
              elsif answers[:cg_04] == "Not applicable"
                if answers[:cg_04_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "cg_05"
              if answers[:cg_05] == "Information available"
                if answers[:cg_05_option1_checkbox1].present? && answers[:cg_05_option11_number1].present?
                  local_score += get_cg_05_sub_value(answers[:cg_05_option11_number1].to_f)
                end
                if answers[:cg_05_option1_checkbox2].present? && answers[:cg_05_option12_number1].present?
                  local_score += get_cg_05_sub_value(answers[:cg_05_option12_number1].to_f)
                end
              elsif answers[:cg_05] == "Not applicable"
                if answers[:cg_05_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "cg_06"
              if answers[:cg_06] == "A board level Sustainability committee is present (please name)"
                local_score += 100
              elsif answers[:cg_06] == "Sustainability committee led by the top management"
                local_score += 70
              elsif answers[:cg_06] == "An advisory committee is present (not at board level)"
                local_score += 50
              elsif answers[:cg_06] == "Ad-hoc engagement on various issues with the relevant teams"
                local_score += 30
              elsif answers[:cg_06] == "Not applicable"
                if answers[:cg_06_vb_option6_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "be_01"
              if answers[:be_01] == "Yes, the organization has a code of conduct/ethics policy"
                local_score += 100
              elsif answers[:be_01] == "Not applicable"
                if answers[:be_01_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "be_04"
              if answers[:be_04] == "Yes, the organization has an ethics and compliance officer (Please give name and designation)"
                local_score += 100
              elsif answers[:be_04] == "It is managed by HR"
                local_score += 50
              elsif answers[:be_04] == "It is managed by another department (Please mention)"
                local_score += 50
              elsif answers[:be_04] == "Not applicable"
                if answers[:be_04_vb_option6_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "rm_01"
              if answers[:rm_01] == "Yes, there is a senior person responsible for risk management beside the CEO/CFO/COO/audit committee head (Please provide name and designation)"
                local_score += 100
              elsif answers[:rm_01] == "Not applicable"
                if answers[:rm_01_vb_option7_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "td_01"
              if answers[:td_01] == "More than 50%"
                local_score += 100
              elsif answers[:td_01] == "25–50%"
                local_score += 60
              elsif answers[:td_01] == "Below 25%"
                local_score += 40
              elsif answers[:td_01] == "Not applicable"
                if answers[:td_01_vb_option7_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "em_02"
              if answers[:em_02] == "A board member/board level committee"
                local_score += 100
              elsif answers[:em_02] == "A senior management team member"
                local_score += 75
              elsif answers[:em_02] == "Any other manager"
                local_score += 50
              elsif answers[:em_02] == "Not applicable"
                if answers[:em_02_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "em_11"
              if answers[:em_11] == "Amount of environmental fines in past financial year (please provide absolute figures in INR)"
                local_score += 50
              elsif answers[:em_11] == "No environmental fines paid"
                local_score += 100
              elsif answers[:em_11] == "Not applicable"
                if answers[:em_11_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "cg_08"
              if answers[:cg_08] == "Information available"
                if answers[:cg_08_option11_number1].present?
                  case answers[:cg_08_option11_number1].to_f
                  when 0..50.99
                    local_score = 100
                  when 51..100
                    local_score = 50
                  else
                    local_score = 0
                  end
                end
              elsif answers[:cg_08] == "Not applicable"
                if answers[:cg_08_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "td_02"
              if answers[:td_02] == 'The sustainability report is'
                if answers[:td_02_option1_radio] == 'Internally assured'
                  local_score += 25
                elsif answers[:td_02_option1_radio] == 'Externally assured in line with international standards (such as AA1000 and ISAE 3000)'
                  local_score += 50
                  if answers[:td_02_option12_checkbox1].present?
                    local_score += 10
                  end
                  if answers[:td_02_option12_checkbox2].present?
                    local_score += 15
                  end
                  if answers[:td_02_option12_checkbox3].present?
                    local_score += 15
                  end
                  if answers[:td_02_option12_checkbox4].present?
                    local_score += 10
                  end
                end
              elsif answers[:td_02] == "Not applicable"
                if answers[:td_02_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hr_02"
              if answers[:hr_02] == "The organization is publicly committed to human rights by"
                if answers[:hr_02_option1_checkbox1].present?
                  local_score += 50
                end
                if answers[:hr_02_option1_checkbox2].present?
                  local_score += 50
                end
              elsif answers[:hr_02] == "The organization is committed to human rights, but not publicly"
                if answers[:hr_02_option2_checkbox1].present?
                  local_score += 25
                end
                if answers[:hr_02_option2_checkbox2].present?
                  local_score += 25
                end
              elsif answers[:hr_02] == "No, the organization does not have a formal human rights policy but the human rights issues are addressed in either of the ways: code of conduct, process, part of a different policy (give details of policy)"
                local_score = 50
              elsif answers[:hr_02] == "Not applicable"
                if answers[:hr_02_vb_option6_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "ohs_06"
              if answers[:ohs_06] == "Number of fatalities provided"
                if answers[:ohs_06_option1_number1].present?
                  if answers[:ohs_06_option1_number1].to_i == 0
                    local_score += 50
                  else
                    local_score += 0
                  end
                end
                if answers[:ohs_06_option1_number2].present?
                  if answers[:ohs_06_option1_number2].to_i == 0
                    local_score += 50
                  else
                    local_score += 0
                  end
                end
              elsif answers[:ohs_06] == "Not applicable"
                if answers[:ohs_06_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "sc_02"
              if answers[:sc_02] == "Yes, the code is part of the contractual agreement with the tier I suppliers for following % of suppliers"
                if answers[:sc_02_option1_number1].present?
                  case answers[:sc_02_option1_number1].to_f
                  when 75..100
                    local_score += 100
                  when 50..74.99
                    local_score += 50
                  when 25..49.99
                    local_score += 25
                  when 0..24.99
                    local_score += 10
                  else
                    local_score = 0
                  end
                end
              elsif answers[:sc_02] == "No, it is communicated separately to all suppliers"
                local_score = 50
              elsif answers[:sc_02] == "Not applicable"
                if answers[:sc_02_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "pr_05"
              if answers[:pr_05] == "Total amount of fines/penalties paid in past five years (please provide absolute figures in INR)"
                if answers[:pr_05_option1_number1].present? && (answers[:pr_05_option1_number1].to_i == 0)
                  local_score += 100
                else
                  local_score = 0
                end
              elsif answers[:pr_05] == "No cases of non-compliance in the past five years"
                local_score += 100
              elsif answers[:pr_05] == "Not applicable"
                if answers[:pr_05_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "pr_06"
              if answers[:pr_06] == "Percentage of cases resolved"
                if answers[:pr_06_option1_number1].present?
                  case answers[:pr_06_option1_number1].to_f
                  when 80..100
                    local_score += 100
                  when 50..79.99
                    local_score += 70
                  when 20..49.99
                    local_score += 40
                  when 0..19.99
                    local_score += 20
                  else
                    local_score = 0
                  end
                end
              elsif answers[:pr_06] == "Not applicable"
                if answers[:pr_06_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hr_06"
              if answers[:hr_06] == "Percentage of cases resolved"
                (1..5).each do |option|
                  if answers[('hr_06_option1_radio' + option.to_s).to_sym].present?
                    if answers[('hr_06_option1_radio' + option.to_s).to_sym] == "Data available"
                      if answers[('hr_06_option1' + option.to_s + '_number1').to_sym].present? && (answers[('hr_06_option1' + option.to_s + '_number1').to_sym].to_f > 49)
                        local_score += get_hr_06_sub_value(answers[('hr_06_option1' + option.to_s + '_number1').to_sym].to_f)
                      end
                    elsif answers[('hr_06_option1_radio' + option.to_s).to_sym] == "No Cases"
                      local_score += 20
                    end
                  end
                end
              elsif answers[:hr_06] == "No complaints on human rights issues were received in the past financial year"
                local_score += 100
              elsif answers[:hr_06] == "Not applicable"
                if answers[:hr_06_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hr_08"
              if answers[:hr_08] == "Percentage indicated for permanent & other than permanent workforce separately"
                if answers[:hr_08_option1_checkbox1].present? && answers[:hr_08_option11_number1].present? && (answers[:hr_08_option11_number1].to_f > 9)
                  local_score += get_hr_08_sub_value(answers[:hr_08_option11_number1].to_f)
                end
                if answers[:hr_08_option1_checkbox2].present? && answers[:hr_08_option12_number1].present? && (answers[:hr_08_option12_number1].to_f > 9)
                  local_score += get_hr_08_sub_value(answers[:hr_08_option12_number1].to_f)
                end
                if answers[:hr_08_option1_checkbox3].present? && answers[:hr_08_option13_number1].present? && (answers[:hr_08_option13_number1].to_f > 9)
                  local_score += get_hr_08_sub_value(answers[:hr_08_option13_number1].to_f)
                end
                if answers[:hr_08_option1_checkbox4].present? && answers[:hr_08_option14_number1].present? && (answers[:hr_08_option14_number1].to_f > 9)
                  local_score += get_hr_08_sub_value(answers[:hr_08_option14_number1].to_f)
                end
              elsif answers[:hr_08] == "Separate data for permanent & other than permanent workforce not available. However, breakup for total workforce available"
                if answers[:hr_08_option2_checkbox1].present? && answers[:hr_08_option21_number1].present? && (answers[:hr_08_option21_number1].to_f > 9)
                  local_score += get_hr_08_sub_value(answers[:hr_08_option21_number1].to_f)
                end
                if answers[:hr_08_option2_checkbox2].present? && answers[:hr_08_option22_number1].present? && (answers[:hr_08_option22_number1].to_f > 9)
                  local_score += get_hr_08_sub_value(answers[:hr_08_option22_number1].to_f)
                end
              elsif answers[:hr_08] == "Not applicable"
                if answers[:hr_08_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hr_09"
              if answers[:hr_09] == "Percentage indicated for permanent & other than permanent workforce separately"
                if answers[:hr_09_option1_checkbox1].present? && answers[:hr_09_option11_number1].present? && (answers[:hr_09_option11_number1].to_f > 0)
                  local_score += get_hr_09_sub_value(answers[:hr_09_option11_number1].to_f)
                end
                if answers[:hr_09_option1_checkbox2].present? && answers[:hr_09_option12_number1].present? && (answers[:hr_09_option12_number1].to_f > 0)
                  local_score += get_hr_09_sub_value(answers[:hr_09_option12_number1].to_f)
                end
                if answers[:hr_09_option1_checkbox3].present? && answers[:hr_09_option13_number1].present? && (answers[:hr_09_option13_number1].to_f > 0)
                  local_score += get_hr_09_sub_value(answers[:hr_09_option13_number1].to_f)
                end
                if answers[:hr_09_option1_checkbox4].present? && answers[:hr_09_option14_number1].present? && (answers[:hr_09_option14_number1].to_f > 0)
                  local_score += get_hr_09_sub_value(answers[:hr_09_option14_number1].to_f)
                end
              elsif answers[:hr_09] == "Separate data for permanent & other than permanent workforce not available. However, breakup for total workforce available"
                if answers[:hr_09_option2_checkbox1].present? && answers[:hr_09_option21_number1].present? && (answers[:hr_09_option21_number1].to_f > 0)
                  local_score += get_hr_09_sub_value(answers[:hr_09_option21_number1].to_f)
                end
                if answers[:hr_09_option2_checkbox2].present? && answers[:hr_09_option22_number1].present? && (answers[:hr_09_option22_number1].to_f > 0)
                  local_score += get_hr_09_sub_value(answers[:hr_09_option22_number1].to_f)
                end
              elsif answers[:hr_09] == "Not applicable"
                if answers[:hr_09_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hr_10"
              if answers[:hr_10] == "Percentage indicated"
                if answers[:hr_10_option1_checkbox1].present? && answers[:hr_10_option11_number1].present? && (answers[:hr_10_option11_number1].to_f > 0)
                  local_score += get_hr_10_sub_value(answers[:hr_10_option11_number1].to_f)
                end
                if answers[:hr_10_option1_checkbox2].present? && answers[:hr_10_option12_number1].present? && (answers[:hr_10_option12_number1].to_f > 0)
                  local_score += get_hr_10_sub_value(answers[:hr_10_option12_number1].to_f)
                end
                if answers[:hr_10_option1_checkbox3].present? && answers[:hr_10_option13_number1].present? && (answers[:hr_10_option13_number1].to_f > 0)
                  local_score += get_hr_10_sub_value(answers[:hr_10_option13_number1].to_f)
                end
                if answers[:hr_10_option1_checkbox4].present? && answers[:hr_10_option14_number1].present? && (answers[:hr_10_option14_number1].to_f > 0)
                  local_score += get_hr_10_sub_value(answers[:hr_10_option14_number1].to_f)
                end
              elsif answers[:hr_10] == "Gender segregated data not available. However, data available on percentage of total employees covered and total workers covered"
                if answers[:hr_10_option2_checkbox1].present? && answers[:hr_10_option21_number1].present? && (answers[:hr_10_option21_number1].to_f > 0)
                  local_score += get_hr_10_sub_value(answers[:hr_10_option21_number1].to_f)
                end
                if answers[:hr_10_option2_checkbox2].present? && answers[:hr_10_option22_number1].present? && (answers[:hr_10_option22_number1].to_f > 0)
                  local_score += get_hr_10_sub_value(answers[:hr_10_option22_number1].to_f)
                end
              elsif answers[:hr_10] == "Not applicable"
                if answers[:hr_10_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hc_02"
              if answers[:hc_02] == "Information Available"
                if answers[:hc_02_option1_checkbox1].present? && answers[:hc_02_option11_number1].present? && (answers[:hc_02_option11_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_02_option11_number1].to_f)
                end
                if answers[:hc_02_option1_checkbox2].present? && answers[:hc_02_option12_number1].present? && (answers[:hc_02_option12_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_02_option12_number1].to_f)
                end
                if answers[:hc_02_option1_checkbox3].present? && answers[:hc_02_option13_number1].present? && (answers[:hc_02_option13_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_02_option13_number1].to_f)
                end
                if answers[:hc_02_option1_checkbox4].present? && answers[:hc_02_option14_number1].present? && (answers[:hc_02_option14_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_02_option14_number1].to_f)
                end
              elsif answers[:hc_02] == "Segregated data by gender not available. However, data available on overall % of employees & workers who attended training & development programs"
                if answers[:hc_02_option2_checkbox1].present? && answers[:hc_02_option21_number1].present? && (answers[:hc_02_option21_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_02_option21_number1].to_f)
                end
                if answers[:hc_02_option2_checkbox2].present? && answers[:hc_02_option22_number1].present? && (answers[:hc_02_option22_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_02_option22_number1].to_f)
                end
              elsif answers[:hc_02] == "Not applicable"
                if answers[:hc_02_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hc_03"
              if answers[:hc_03] == "Percentage of employees/workers who received performance & career development review:"
                if answers[:hc_03_option1_checkbox1].present? && answers[:hc_03_option11_number1].present? && (answers[:hc_03_option11_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_03_option11_number1].to_f)
                end
                if answers[:hc_03_option1_checkbox2].present? && answers[:hc_03_option12_number1].present? && (answers[:hc_03_option12_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_03_option12_number1].to_f)
                end
                if answers[:hc_03_option1_checkbox3].present? && answers[:hc_03_option13_number1].present? && (answers[:hc_03_option13_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_03_option13_number1].to_f)
                end
                if answers[:hc_03_option1_checkbox4].present? && answers[:hc_03_option14_number1].present? && (answers[:hc_03_option14_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_03_option14_number1].to_f)
                end
              elsif answers[:hc_03] == "Segregated data by gender not available. However, data available on overall % of employees & workers who received performance & career development review"
                if answers[:hc_03_option2_checkbox1].present? && answers[:hc_03_option21_number1].present? && (answers[:hc_03_option21_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_03_option21_number1].to_f)
                end
                if answers[:hc_03_option2_checkbox2].present? && answers[:hc_03_option22_number1].present? && (answers[:hc_03_option22_number1].to_f > 5)
                  local_score += get_hc_02_03_sub_value(answers[:hc_03_option22_number1].to_f)
                end
              elsif answers[:hc_03] == "Not applicable"
                if answers[:hc_03_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "be_02", "be_05", "be_06", "rm_04", "rm_05", "ohs_07", "ohs_08", "em_10", "sc_01", "hr_03", "hr_04"
              case answers[question_code.to_sym]
              when "The code of conduct/ethics policy covers"
                options_score = [10, 20, 10, 10, 20, 10, 10, 10, 0]
              when "Yes, the organization has a whistle-blowing mechanism, which is available to"
                options_score = [50, 50, 0, 0, 0, 0, 0, 0, 0]
              when "Following systems are in place to ensure effective implementation of Code of conduct/ethics policy", "Yes, following aspects are integrated into multidisciplinary company-wide risk management process"
                options_score = [25, 25, 25, 25, 0, 0, 0, 0, 0]
              when "Strategies used by organization are listed below"
                options_score = [15, 15, 15, 15, 15, 15, 10, 0, 0]
              when "Yes, the organization offers"
                options_score = [20, 10, 20, 20, 10, 10, 10, 0, 0]
              when "Information available"
                options_score = [20, 20, 20, 20, 20, 0, 0, 0, 0]
              when "The organization has taken measures to phase out/ban SUP"
                options_score = [25, 25, 25, 25, 0, 0, 0, 0, 0]
              when "Yes, the organisation has a Supplier Policy/Code of conduct and the code covers"
                options_score = [10, 15, 10, 10, 10, 10, 10, 10, 15]
              when "Yes, there is a policy for"
                options_score = [20, 10, 10, 20, 20, 10, 10, 0, 0]
              when "The policy applies to"
                options_score = [30, 10, 20, 20, 20, 0, 0, 0, 0]
              when "Not applicable"
                options_score = [0, 0, 0, 0, 0, 0, 0, 0, 0]
                if answers[(question_code + '_vb_option3_radio').to_sym].present? && answers[(question_code + '_vb_option3_radio').to_sym] == "Reason provided are justified and it is not applicable" ||
                  answers[(question_code + '_vb_option4_radio').to_sym].present? && answers[(question_code + '_vb_option4_radio').to_sym] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              else
                options_score = [0, 0, 0, 0, 0, 0, 0, 0, 0]
              end

              if answers[question_code.to_sym] != "Not applicable" || answers[question_code.to_sym] != "No code of conduct/ethics policy" ||
                answers[question_code.to_sym] != "No information available" || answers[question_code.to_sym] != "No whistle-blowing mechanism" ||
                answers[question_code.to_sym] != "No, the organization do not have any strategies to promote and enhance an effective risk culture" ||
                answers[question_code.to_sym] != "Adhoc measures to manage overtime work" || answers[question_code.to_sym] != "The organization has not taken measures to phase out/ban SUP" ||
                answers[question_code.to_sym] != "No formal policy/code of conduct for suppliers" || answers[question_code.to_sym] != "No formal human rights policy is in place" ||
                answers[question_code.to_sym] != "No, the organization does not have a formal human rights policy in place/No separate policies for the above issues"
                local_score = get_local_score(question_code, answers, options_score)
              end
            when "hr_07"
              if answers[:hr_07] == "Yes there is a mechanism in place, and percentage of grievances resolved are"
                if answers[:hr_07_option2_number1].present? && (answers[:hr_07_option2_number1].to_f > 0)
                  local_score += 50 + ((50 * answers[:hr_07_option2_number1].to_f) / 100)
                end
              elsif answers[:hr_07] == "Yes there is a mechanism in place, but the percentage of grievances resolved is not known"
                local_score += 50
              elsif answers[:hr_07] == "Not applicable"
                if answers[:hr_07_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "em_01"
              em_01_temp_score = 0
              if answers[:em_01] == "Yes, the organization has a certified Environmental Management system that covers"
                if answers[:em_01_option11_number1].present? && (answers[:em_01_option11_number1].to_f > 0)
                  em_01_temp_score += answers[:em_01_option11_number1].to_f
                end
                if answers[:em_01_option12_number1].present? && (answers[:em_01_option12_number1].to_f > 0)
                  em_01_temp_score += answers[:em_01_option12_number1].to_f
                end
                local_score = (em_01_temp_score >= 100) ? 100 : em_01_temp_score
              elsif answers[:em_01] == "Not applicable"
                if answers[:em_01_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "csr_06"
              if answers[:csr_06] == "Yes, the organization has following systems in place"
                if answers[:csr_06_option1_checkbox1].present?
                  local_score += 40
                end
                if answers[:csr_06_option1_checkbox2].present?
                  local_score += 40
                end
                if answers[:csr_06_option1_checkbox3].present?
                  if answers[:csr_06_vb_option13_radio].present? && answers[:csr_06_vb_option13_radio] == "The other system mentioned is relevant"
                    local_score += 20
                  end
                end
              elsif answers[:csr_06] == "The organization is currently developing systems"
                local_score += 20
              elsif answers[:csr_06] == "Not applicable"
                if answers[:csr_06_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "ohs_01", "csr_03", "em_03", "sc_03", "sc_04", "sc_05", "bd_01", "bd_05", "pr_04"
              case answers[question_code.to_sym]
              when "Yes, the organization has occupational health & safety management system in place, and covers"
                options_score = [25, 25, 25, 25, 0, 0]
              when "Description provided"
                options_score = [20, 20, 20, 20, 20, 0]
              when "Information available"
                if question_code == "em_03"
                  options_score = [30, 30, 40, 0, 0, 0]
                elsif question_code == "pr_04"
                  options_score = [25, 25, 25, 25, 0, 0]
                else
                  options_score = [0, 0, 0, 0, 0, 0]
                end
              when "Following measures have been taken for effective integration of sustainability into procurement decisions"
                options_score = [20, 15, 15, 15, 15, 20]
              when "Yes, initiatives taken"
                options_score = [50, 25, 25, 0, 0, 0]
              when "Yes, the organization has set following sustainability related target in its supply chain"
                options_score = [40, 40, 20, 0, 0, 0]
              when "Information Available"
                options_score = [30, 40, 30, 0, 0, 0]
              when "Details provided for biodiversity aspects addressed under these management systems"
                options_score = [50, 10, 10, 10, 10, 10]
              when "Not applicable"
                options_score = [0, 0, 0, 0, 0, 0]
                if answers[(question_code + '_vb_option3_radio').to_sym].present? && answers[(question_code + '_vb_option3_radio').to_sym] == "Reason provided are justified and it is not applicable" ||
                  answers[(question_code + '_vb_option4_radio').to_sym].present? && answers[(question_code + '_vb_option4_radio').to_sym] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              else
                options_score = [0, 0, 0, 0, 0, 0]
              end

              if answers[question_code.to_sym] != "Not applicable" || answers[question_code.to_sym] != "No, there is no occupational health & safety managemet system in place" ||
                answers[question_code.to_sym] != "No commitment" || answers[question_code.to_sym] != "The organization has not set any sustainability related targets in its supply chain"
                local_score = get_validate_c_box_add_score(question_code, answers, options_score)
              end
            when "pr_03"
              if answers[:pr_03] == "Information available"
                if answers[:pr_03_vb_option1_radio] == "For 2-3 products"
                  if answers[:pr_03_vb_option11_checkbox1].present?
                    local_score += 50
                  end
                  if answers[:pr_03_vb_option11_checkbox2].present?
                    local_score += 50
                  end
                elsif answers[:pr_03_vb_option1_radio] == "Modification and benefits mentioned for only one relevant product"
                  local_score += 50
                elsif answers[:pr_03_vb_option1_radio] == "Only products mentioned but not benefits"
                  local_score += 25
                end
              elsif answers[:pr_03] == "Not applicable"
                if answers[:pr_03_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hc_01"
              if answers[:hc_01] == "Yes, process in place"
                if answers[:hc_01_vb_option1_radio] == "Well defined process"
                  if answers[:hc_01_vb_option11_checkbox1].present?
                    local_score += 25
                  end
                  if answers[:hc_01_vb_option11_checkbox2].present?
                    local_score += 25
                  end
                  if answers[:hc_01_vb_option11_checkbox3].present?
                    local_score += 50
                  end
                elsif answers[:hc_01_vb_option1_radio] == "Ad-hoc process in place to identify training needs"
                  local_score += 25
                end
              elsif answers[:hc_01] == "Not applicable"
                if answers[:hc_01_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "csr_01"
              if answers[:csr_01] == "Yes, the focus areas are clearly identified in the CSR Policy"
                if answers[:csr_01_vb_option1_radio] == "The focus areas are identified"
                  local_score += 100
                elsif answers[:csr_01_vb_option1_radio] == "Specific focus areas are not identified in the policy; it's a list of Schedule VII"
                  local_score += 30
                end
              elsif answers[:csr_01] == "There is no clear policy but focus areas are defined"
                local_score += 20
              elsif answers[:csr_01] == "Not applicable"
                if answers[:csr_01_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "csr_05"
              if answers[:csr_05] == "Description provided"
                if answers[:csr_05_vb_option1_radio] == "Board/top management's monitoring entails"
                  if answers[:csr_05_vb_option11_checkbox1].present?
                    local_score += 20
                  end
                  if answers[:csr_05_vb_option11_checkbox2].present?
                    local_score += 30
                  end
                  if answers[:csr_05_vb_option11_checkbox3].present?
                    local_score += 30
                  end
                  if answers[:csr_05_vb_option11_checkbox4].present?
                    local_score += 20
                  end
                end
              elsif answers[:csr_05] == "Not applicable"
                if answers[:csr_05_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "bd_04"
              if answers[:bd_04] == "Information Available"
                if answers[:bd_04_vb_option1_checkbox1].present?
                  if answers[:bd_04_vb_option11_radio] == "All reasons are acceptable"
                    local_score += 50
                  elsif answers[:bd_04_vb_option11_radio] == "2 reasons are acceptable"
                    local_score += 30
                  elsif answers[:bd_04_vb_option11_radio] == "Only 1 reason is acceptable"
                    local_score += 20
                  end
                end
                if answers[:bd_04_vb_option1_checkbox2].present?
                  if answers[:bd_04_vb_option12_radio] == "All reasons are acceptable"
                    local_score += 50
                  elsif answers[:bd_04_vb_option12_radio] == "2 reasons are acceptable"
                    local_score += 30
                  elsif answers[:bd_04_vb_option12_radio] == "Only 1 reason is acceptable"
                    local_score += 20
                  end
                end
              elsif answers[:bd_04] == "The organization complied with all environmental approvals/clearances"
                local_score += 100
              elsif answers[:bd_04] == "Not applicable"
                if answers[:bd_04_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "pr_01"
              if answers[:pr_01] == "The organization is committed to sustainable products, through"
                if answers[:pr_01_vb_option1_checkbox1].present?
                  local_score += 40
                end
                if answers[:pr_01_vb_option1_checkbox2].present?
                  local_score += 30
                end
                if answers[:pr_01_vb_option1_checkbox3].present?
                  local_score += 30
                end
              elsif answers[:pr_01] == "There is no product commitment, but it is committed toward doing business sustainably"
                local_score += 10
              elsif answers[:pr_01] == "Not applicable"
                if answers[:pr_01_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "bd_03"
              bd_03_temp_score = 0
              if answers[:bd_03] == "Information Available"
                (1..3).each do |option|
                  if answers[('bd_03_vb_option1' + option.to_s + '_radio').to_sym].present? && answers[('bd_03_vb_option1' + option.to_s + '_radio').to_sym] == "Risks/opportunities identified"
                    if answers[('bd_03_vb_option1' + option.to_s + '1_checkbox1').to_sym].present?
                      bd_03_temp_score += 5
                    end
                    if answers[('bd_03_vb_option1' + option.to_s + '1_checkbox2').to_sym].present?
                      bd_03_temp_score += 5
                    end
                    if answers[('bd_03_vb_option1' + option.to_s + '1_checkbox3').to_sym].present?
                      bd_03_temp_score += 5
                    end
                    if answers[('bd_03_vb_option1' + option.to_s + '1_checkbox4').to_sym].present?
                      bd_03_temp_score += 5
                    end
                    if answers[('bd_03_vb_option1' + option.to_s + '1_checkbox5').to_sym].present?
                      bd_03_temp_score += 10
                    end
                  end
                end
                local_score = (bd_03_temp_score == 90) ? 100 : bd_03_temp_score
              elsif answers[:bd_03] == "Not applicable"
                if answers[:bd_03_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "bd_07"
              if answers[:bd_07] == "Information Available"
                (1..2).each do |option|
                  if answers[('bd_07_vb_option1' + option.to_s + '_radio').to_sym].present?
                    if answers[('bd_07_vb_option1' + option.to_s + '_radio').to_sym] == "Initiatives mentioned"
                      if answers[('bd_07_vb_option1' + option.to_s + '1_checkbox1').to_sym].present?
                        local_score += 10
                      end
                      if answers[('bd_07_vb_option1' + option.to_s + '1_checkbox2').to_sym].present?
                        local_score += 20
                      end
                      if answers[('bd_07_vb_option1' + option.to_s + '1_checkbox3').to_sym].present?
                        local_score += 20
                      end
                    elsif answers[('bd_07_vb_option1' + option.to_s + '_radio').to_sym] == "Adhoc initiatives mentioned"
                      local_score += 10
                    end
                  end
                end
              elsif answers[:bd_07] == "Not applicable"
                if answers[:bd_07_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "td_03"
              if answers[:td_03_vb_option1_radio].present?
                if answers[:td_03_vb_option1_radio] == "All material issues identified have KPIs and Targets"
                  local_score += 100
                elsif answers[:td_03_vb_option1_radio] == "Most material issues identified have KPIs and Targets"
                  local_score += 75
                elsif answers[:td_03_vb_option1_radio] == "Some material issues identified have KPIs and Targets"
                  local_score += 50
                elsif answers[:td_03_vb_option1_radio] == "Material issues identified but no details for any available"
                  local_score += 25
                end
              elsif answers[:td_03] == "Not applicable"
                if answers[:td_03_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "td_04"
              if answers[:td_04_vb_option1_radio].present?
                if answers[:td_04_vb_option1_radio] == "Financial implication provided for all identified material issues"
                  local_score += 100
                elsif answers[:td_04_vb_option1_radio] == "Financial implication provided for 50% identified material issues"
                  local_score += 60
                end
              elsif answers[:td_04] == "Not applicable"
                if answers[:td_04_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "rm_02"
              if answers[:rm_02_vb_option1_radio].present?
                if answers[:rm_02_vb_option1_radio] == "Audit function is independent of risk management function"
                  local_score += 100
                elsif answers[:rm_02_vb_option1_radio] == "Audit function is not independent of risk management function"
                  local_score += 20
                end
              elsif answers[:rm_02] == "Not applicable"
                if answers[:rm_02_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "bd_06"
              if answers[:bd_06] == "Information Available"
                (1..2).each do |option|
                  if answers[('bd_06_option1_checkbox' + option.to_s).to_sym].present?
                    (1..3).each do |sub_option|
                      if answers[('bd_06_vb_option1' + option.to_s + '_checkbox' + sub_option.to_s).to_sym].present?
                        local_score += 10
                      end
                    end
                  end
                end
                if answers[:bd_06_option1_checkbox3].present?
                  local_score += 40
                end
              elsif answers[:bd_06] == "Not applicable"
                if answers[:bd_06_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "csr_04"
              if answers[:csr_04] == "Information available"
                if answers[:csr_04_vb_option1_checkbox1].present? && answers[:csr_04_vb_option11_radio].present?
                  if answers[:csr_04_vb_option11_radio] == "Output, outcome, impact, SCV mentioned are relevant to the CSR activity, impacts are qualitative and quantitative in nature"
                    local_score += 30
                  elsif answers[:csr_04_vb_option11_radio] == "Output, outcome, impact, & SCV mentioned are relevant to the CSR activity, impacts are only qualitative in nature"
                    local_score += 25
                  elsif answers[:csr_04_vb_option11_radio] == "SCV is not calculated; impacts, output & outcome are relevant to the CSR activity and are qualitatitive & quantitative"
                    local_score += 20
                  elsif answers[:csr_04_vb_option11_radio] == "No impacts mentioned, but output and outcome mentioned are relevant to the CSR activity and are qualitative and quantitative in nature"
                    local_score += 15
                  elsif answers[:csr_04_vb_option11_radio] == "No impacts mentioned, but output and outcome mentioned are relevant to the CSR activity and are qualitative in nature"
                    local_score += 5
                  elsif answers[:csr_04_vb_option11_radio] == "Only output mentioned and they are relevant to the CSR activity"
                    local_score += 5
                  end
                end
                (2..3).each do |option|
                  if answers[('csr_04_vb_option1_checkbox' + option.to_s).to_sym].present? && answers[('csr_04_vb_option1' + option.to_s + '_radio').to_sym].present?
                    if answers[('csr_04_vb_option1' + option.to_s + '_radio').to_sym] == "Output, outcome and impact mentioned are relevant to the CSR activity, impacts are qualitative and quantitative in nature"
                      local_score += 30
                    elsif answers[('csr_04_vb_option1' + option.to_s + '_radio').to_sym] == "Output, outcome and impact mentioned are relevant to the CSR activity, impacts are only qualitative in nature"
                      local_score += 25
                    elsif answers[('csr_04_vb_option1' + option.to_s + '_radio').to_sym] == "SCV is not calculated; impacts, output & outcome are relevant to the CSR activity and are qualitatitive & quantitative"
                      local_score += 20
                    elsif answers[('csr_04_vb_option1' + option.to_s + '_radio').to_sym] == "No impacts mentioned, but output and outcome mentioned are relevant to the CSR activity and are qualitative and quantitative in nature"
                      local_score += 15
                    elsif answers[('csr_04_vb_option1' + option.to_s + '_radio').to_sym] == "No impacts mentioned, but output and outcome mentioned are relevant to the CSR activity and are qualitative in nature"
                      local_score += 5
                    elsif answers[('csr_04_vb_option1' + option.to_s + '_radio').to_sym] == "Only output mentioned and they are relevant to the CSR activity"
                      local_score += 5
                    end
                  end
                end
              elsif answers[:csr_04] == "Not applicable"
                if answers[:csr_04_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "rm_03"
              rm_03_temp_score = 0
              if answers[:rm_03] == "Yes, the organization identifies significant risks and develops mitigation strategy for them"
                if answers[:rm_03_vb_option1_radio1].present?
                  if answers[:rm_03_vb_option1_radio1] == "Impacts on business are well defined for two or more risks"
                    rm_03_temp_score += 30
                  elsif answers[:rm_03_vb_option1_radio1] == "Impacts on business are well defined for only one risk"
                    rm_03_temp_score += 15
                  end
                end
                if answers[:rm_03_vb_option1_radio2].present?
                  if answers[:rm_03_vb_option1_radio2] == "Coherent strategies and mitigation actions defined to deal with the all risks that are identified"
                    rm_03_temp_score += 30
                  elsif answers[:rm_03_vb_option1_radio2] == "Coherent strategies and mitigation actions defined to deal with the less than two risks that are identified"
                    rm_03_temp_score += 15
                  end
                end
                if answers[:rm_03_vb_option1_radio3].present?
                  if answers[:rm_03_vb_option1_radio3] == "Financial impacts are well defined for two or more risks"
                    rm_03_temp_score += 40
                  elsif answers[:rm_03_vb_option1_radio3] == "Financial impacts are well defined for only one risk"
                    rm_03_temp_score += 20
                  end
                end
                local_score += (rm_03_temp_score > 100) ? 100 : rm_03_temp_score
              elsif answers[:csr_04] == "Not applicable"
                if answers[:csr_04_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "be_03"
              if answers[:be_03] == "Information available"
                (1..5).each do |option|
                  if answers[('be_03_table1_row' + option.to_s + '_percentage1').to_sym].present? && (answers[('be_03_table1_row' + option.to_s + '_percentage1').to_sym].to_f > 0)
                    local_score += answers[('be_03_table1_row' + option.to_s + '_percentage1').to_sym].to_f * 0.2
                  end
                end
              elsif answers[:be_03] == "Not applicable"
                if answers[:be_03_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "ohs_02"
              if answers[:ohs_02] == "Information Available on %operations assessed for"
                if answers[:ohs_02_option1_checkbox1].present? && answers[:ohs_02_option11_number1].present? && (answers[:ohs_02_option11_number1].to_f > 0)
                  local_score += (answers[:ohs_02_option11_number1].to_f * 0.5)
                end
                if answers[:ohs_02_option1_checkbox2].present? && answers[:ohs_02_option12_number1].present? && (answers[:ohs_02_option12_number1].to_f > 0)
                  local_score += (answers[:ohs_02_option12_number1].to_f * 0.5)
                end
              elsif answers[:ohs_02] == "Not applicable"
                if answers[:ohs_02_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "bd_02"
              if answers[:bd_02] == "Information Available"
                if answers[:bd_02_option1_checkbox1].present?
                  if answers[:bd_02_option11_number1].present? && (answers[:bd_02_option11_number1].to_f > 0)
                    local_score += (answers[:bd_02_option11_number1].to_f * 0.25)
                  end
                  if answers[:bd_02_option11_number2].present? && (answers[:bd_02_option11_number2].to_f > 0)
                    local_score += (answers[:bd_02_option11_number2].to_f * 0.25)
                  end
                end
                if answers[:bd_02_option1_checkbox2].present?
                  if answers[:bd_02_vb_option12_checkbox1].present?
                    local_score += 25
                  end
                  if answers[:bd_02_vb_option12_checkbox2].present?
                    local_score += 25
                  end
                end
              elsif answers[:bd_02] == "Not applicable"
                if answers[:bd_02_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "be_07"
              if answers[:be_07] == "Number of cases reported" && answers[:be_07_option1_number1].present? && (answers[:be_07_option1_number1].to_i == 0)
                local_score += 100
              elsif answers[:be_07] == "Not applicable"
                if answers[:be_07_vb_option5_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "rm_06"
              if answers[:rm_06] == "Total amount of fines/penalties paid in the past financial year (please provide absolute figures in INR)" && answers[:rm_06_option1_number1].present?
                local_score += (answers[:rm_06_option1_number1].to_i == 0) ? 100 : 50
              elsif answers[:rm_06] == "Not applicable"
                if answers[:rm_06_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "cg_07"
              if answers[:cg_07] == "Information available"
                if answers[:cg_07_option1_checkbox1].present?
                  if answers[:cg_07_option11_checkbox1].present?
                    local_score += 10
                  end
                  if answers[:cg_07_option11_checkbox2].present?
                    local_score += 10
                  end
                end
                if answers[:cg_07_option1_checkbox2].present?
                  local_score += 10
                end
                if answers[:cg_07_option1_checkbox3].present?
                  local_score += 20
                end
                if answers[:cg_07_option1_checkbox4].present?
                  if answers[:cg_07_option14_checkbox1].present?
                    local_score += 10
                  end
                  if answers[:cg_07_option14_checkbox2].present?
                    local_score += 10
                  end
                  if answers[:cg_07_vb_option14_radio].present? && answers[:cg_07_vb_option14_radio] == "Acceptable"
                    local_score += 10
                  end
                end
                if answers[:cg_07_option1_checkbox5].present?
                  local_score += 20
                end
              elsif answers[:cg_07] == "Not applicable"
                if answers[:cg_07_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "em_05"
              if answers[:em_05] == "Information available"
                idf_values = { :i => 0, :d => 80, :f => 40 }
                if (answers[:em_05_table1_row3_number3].present? && (answers[:em_05_table1_row3_number3].to_f > 0)) && (answers[:em_05_table1_row4_number3].present? && (answers[:em_05_table1_row4_number3].to_f > 0)) && (answers[:em_04_table1_row1_number3].present? && (answers[:em_04_table1_row1_number3].to_f > 0))
                  if (answers[:em_05_table1_row3_number1].present? && (answers[:em_05_table1_row3_number1].to_f > 0)) && (answers[:em_05_table1_row4_number1].present? && (answers[:em_05_table1_row4_number1].to_f > 0)) && (answers[:em_04_table1_row1_number1].present? && (answers[:em_04_table1_row1_number1].to_f > 0))
                    trend_value = find_trend_type (answers[:em_05_table1_row3_number3].to_f / ((answers[:em_05_table1_row4_number3].to_f / 100) * answers[:em_04_table1_row1_number3].to_f)), (answers[:em_05_table1_row3_number1].to_f / ((answers[:em_05_table1_row4_number1].to_f / 100) * answers[:em_04_table1_row1_number1].to_f))
                    local_score += idf_values[trend_value.to_sym]
                  elsif (answers[:em_05_table1_row3_number2].present? && (answers[:em_05_table1_row3_number2].to_f > 0)) && (answers[:em_05_table1_row4_number2].present? && (answers[:em_05_table1_row4_number2].to_f > 0)) && (answers[:em_04_table1_row1_number2].present? && (answers[:em_04_table1_row1_number2].to_f > 0))
                    trend_value = find_trend_type (answers[:em_05_table1_row3_number3].to_f / ((answers[:em_05_table1_row4_number3].to_f / 100) * answers[:em_04_table1_row1_number3].to_f)), (answers[:em_05_table1_row3_number2].to_f / ((answers[:em_05_table1_row4_number2].to_f / 100) * answers[:em_04_table1_row1_number2].to_f))
                    local_score += idf_values[trend_value.to_sym]
                  end
                end
                if answers[:em_05_option1_checkbox1].present? && answers[:em_05_vb_option11_radio] == "Target set"
                  local_score += 10
                end
                if answers[:em_05_option1_checkbox2].present?
                  local_score += 10
                end
              elsif answers[:em_05] == "Not applicable"
                if answers[:em_05_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "em_06", "em_07", "em_08"
              if answers[question_code.to_sym] == "Information available" || answers[question_code.to_sym] == "Information Available"
                  idf_values = { :i => 0, :d => 80, :f => 40 }

                  if (answers[(question_code + "_table1_row1_number3").to_sym].present? && (answers[(question_code + "_table1_row1_number3").to_sym].to_f > 0)) && (answers[(question_code + "_table1_row2_number3").to_sym].present? && (answers[(question_code + "_table1_row2_number3").to_sym].to_f > 0)) && (answers[:em_04_table1_row1_number3].present? && (answers[:em_04_table1_row1_number3].to_f > 0))
                    if (answers[(question_code + "_table1_row1_number1").to_sym].present? && (answers[(question_code + "_table1_row1_number1").to_sym].to_f > 0)) && (answers[(question_code + "_table1_row2_number1").to_sym].present? && (answers[(question_code + "_table1_row2_number1").to_sym].to_f > 0)) && (answers[:em_04_table1_row1_number1].present? && (answers[:em_04_table1_row1_number1].to_f > 0))
                      trend_value = find_trend_type (answers[(question_code + "_table1_row1_number3").to_sym].to_f / ((answers[(question_code + "_table1_row2_number3").to_sym].to_f / 100) * answers[:em_04_table1_row1_number3].to_f)), (answers[(question_code + "_table1_row1_number1").to_sym].to_f / ((answers[(question_code + "_table1_row2_number1").to_sym].to_f / 100) * answers[:em_04_table1_row1_number1].to_f))
                      local_score += idf_values[trend_value.to_sym]
                    elsif (answers[(question_code + "_table1_row1_number2").to_sym].present? && (answers[(question_code + "_table1_row1_number2").to_sym].to_f > 0)) && (answers[(question_code + "_table1_row2_number2").to_sym].present? && (answers[(question_code + "_table1_row2_number2").to_sym].to_f > 0)) && (answers[:em_04_table1_row1_number2].present? && (answers[:em_04_table1_row1_number2].to_f > 0))
                      trend_value = find_trend_type (answers[(question_code + "_table1_row1_number3").to_sym].to_f / ((answers[(question_code + "_table1_row2_number3").to_sym].to_f / 100) * answers[:em_04_table1_row1_number3].to_f)), (answers[(question_code + "_table1_row1_number2").to_sym].to_f / ((answers[(question_code + "_table1_row2_number2").to_sym].to_f / 100) * answers[:em_04_table1_row1_number2].to_f))
                      local_score += idf_values[trend_value.to_sym]
                    end
                  end

                if answers[(question_code + "_option1_checkbox1").to_sym].present? && answers[(question_code + "_vb_option11_radio").to_sym] == "Target set"
                    local_score += 10
                end
                if answers[(question_code + "_option1_checkbox2").to_sym].present?
                  local_score += 10
                end
              elsif answers[question_code.to_sym] == "Not applicable"
                if answers[(question_code + "_vb_option4_radio").to_sym] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hc_05", "pr_07"
              if answers[question_code.to_sym] == "Information available" || answers[question_code.to_sym] == "Information Available"
                  idf_values = { :i => 80, :d => 0, :f => 50 }
                if answers[(question_code + "_table1_row1_number3").to_sym].present? && (answers[(question_code + "_table1_row1_number3").to_sym].to_f > 0)
                  if answers[(question_code + "_table1_row1_number1").to_sym].present? && (answers[(question_code + "_table1_row1_number1").to_sym].to_f > 0)
                    trend_value = find_trend_type answers[(question_code + "_table1_row1_number3").to_sym].to_f, answers[(question_code + "_table1_row1_number1").to_sym].to_f
                    local_score += idf_values[trend_value.to_sym]
                  elsif answers[(question_code + "_table1_row1_number2").to_sym].present? && (answers[(question_code + "_table1_row1_number2").to_sym].to_f > 0)
                    trend_value = find_trend_type answers[(question_code + "_table1_row1_number3").to_sym].to_f, answers[(question_code + "_table1_row1_number2").to_sym].to_f
                    local_score += idf_values[trend_value.to_sym]
                  end
                end

                if answers[(question_code + "_option1_checkbox1").to_sym].present? && answers[(question_code + "_vb_option11_radio").to_sym] == "Target set"
                    local_score += 20
                end
                if answers[(question_code + "_option1_checkbox2").to_sym].present?
                  local_score += 10
                end
              elsif answers[question_code.to_sym] == "Not applicable"
                if answers[(question_code + "_vb_option4_radio").to_sym] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "ohs_03", "ohs_04", "ohs_05"
              if answers[question_code.to_sym] == "Information available"
                idf_values = { :i => 0, :d => 40, :f => 20 }

                (1..2).each do |option|
                  if answers[(question_code + "_table1_row" + option.to_s + "_number3").to_sym].present? && (answers[(question_code + "_table1_row" + option.to_s + "_number3").to_sym].to_f > 0)
                    if answers[(question_code + "_table1_row" + option.to_s + "_number1").to_sym].present? && (answers[(question_code + "_table1_row" + option.to_s + "_number1").to_sym].to_f > 0)
                      trend_value = find_trend_type answers[(question_code + "_table1_row" + option.to_s + "_number3").to_sym].to_f, answers[(question_code + "_table1_row" + option.to_s + "_number1").to_sym].to_f
                      local_score += idf_values[trend_value.to_sym]
                    elsif answers[(question_code + "_table1_row" + option.to_s + "_number2").to_sym].present? && (answers[(question_code + "_table1_row" + option.to_s + "_number2").to_sym].to_f > 0)
                      trend_value = find_trend_type answers[(question_code + "_table1_row" + option.to_s + "_number3").to_sym].to_f, answers[(question_code + "_table1_row" + option.to_s + "_number2").to_sym].to_f
                      local_score += idf_values[trend_value.to_sym]
                    end
                  end
                end

                if answers[(question_code + "_option1_checkbox1").to_sym].present? && answers[(question_code + "_vb_option11_radio").to_sym] == "Target set"
                  local_score += 20
                end
              elsif answers[question_code.to_sym] == "Not applicable"
                if answers[(question_code + "_vb_option3_radio").to_sym] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hc_04"
              idf_values = { :i => 0, :d => 10, :f => 5 }, { :i => 0, :d => 10, :f => 5 }, { :i => 0, :d => 30, :f => 10 }
              if answers[:hc_04] == "Percentage indicated"
                if answers[:hc_04_option1_checkbox1].present?
                  (1..3).each do |option|
                    if answers[("hc_04_table1_row" + option.to_s + "_number3").to_sym].present? && (answers[("hc_04_table1_row" + option.to_s + "_number3").to_sym].to_f > 0)
                      if answers[("hc_04_table1_row" + option.to_s + "_number1").to_sym].present? && (answers[("hc_04_table1_row" + option.to_s + "_number1").to_sym].to_f > 0)
                        trend_value = find_trend_type answers[("hc_04_table1_row" + option.to_s + "_number3").to_sym].to_f, answers[("hc_04_table1_row" + option.to_s + "_number1").to_sym].to_f
                        local_score += idf_values[option - 1][trend_value.to_sym]
                      elsif answers[("hc_04_table1_row" + option.to_s + "_number2").to_sym].present? && (answers[("hc_04_table1_row" + option.to_s + "_number2").to_sym].to_f > 0)
                        trend_value = find_trend_type answers[("hc_04_table1_row" + option.to_s + "_number3").to_sym].to_f, answers[("hc_04_table1_row" + option.to_s + "_number2").to_sym].to_f
                        local_score += idf_values[option - 1][trend_value.to_sym]
                      end
                    end
                  end
                end

                if answers[:hc_04_option1_checkbox2].present?
                  (1..3).each do |option|
                    if answers[("hc_04_table2_row" + option.to_s + "_number3").to_sym].present? && (answers[("hc_04_table2_row" + option.to_s + "_number3").to_sym].to_f > 0)
                      if answers[("hc_04_table2_row" + option.to_s + "_number1").to_sym].present? && (answers[("hc_04_table2_row" + option.to_s + "_number1").to_sym].to_f > 0)
                        trend_value = find_trend_type answers[("hc_04_table2_row" + option.to_s + "_number3").to_sym].to_f, answers[("hc_04_table2_row" + option.to_s + "_number1").to_sym].to_f
                        local_score += idf_values[option - 1][trend_value.to_sym]
                      elsif answers[("hc_04_table2_row" + option.to_s + "_number2").to_sym].present? && (answers[("hc_04_table2_row" + option.to_s + "_number2").to_sym].to_f > 0)
                        trend_value = find_trend_type answers[("hc_04_table2_row" + option.to_s + "_number3").to_sym].to_f, answers[("hc_04_table2_row" + option.to_s + "_number2").to_sym].to_f
                        local_score += idf_values[option - 1][trend_value.to_sym]
                      end
                    end
                  end
                end
              elsif answers[:hc_04] == "Not applicable"
                if answers[:hc_04_vb_option3_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "pr_02"
              if answers[:pr_02] == "Yes, the organization conducts LCA for its products/services and details are provided below"
                if answers[:pr_02_option1_checkbox1].present? && answers[:pr_02_option1_checkbox1] == "Coverage of the LCA in terms of % of total turnover contributed by products/services for which LCA is conducted"
                  if answers[:pr_02_option11_number1].present? && (answers[:pr_02_option11_number1].to_f > 0)
                    local_score += (answers[:pr_02_option11_number1].to_f / 2)
                  end
                end
                if answers[:pr_02_option1_checkbox2].present?
                  local_score += 30
                end
                if answers[:pr_02_option1_checkbox3].present?
                  local_score += 20
                end
              elsif answers[:pr_02] == "Not applicable"
                if answers[:pr_02_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "hr_05"
              if answers[:hr_05] == "Following systems are in place to ensure effective communication & implementation of HR Policies"
                if answers[:hr_05_option1_checkbox1].present?
                  if answers[:hr_05_option111_number1].present? && (answers[:hr_05_option111_number1].to_f > 0)
                    local_score += (answers[:hr_05_option111_number1].to_f / 5)
                  end
                  if answers[:hr_05_option112_number1].present? && (answers[:hr_05_option112_number1].to_f > 0)
                    local_score += (answers[:hr_05_option112_number1].to_f / 5)
                  end
                end
                if answers[:hr_05_option1_checkbox2].present?
                  local_score += 20
                end
                if answers[:hr_05_option1_checkbox3].present?
                  local_score += 20
                end
                if answers[:hr_05_option1_checkbox4].present?
                  local_score += 20
                end
              elsif answers[:hr_05] == "Not applicable"
                if answers[:hr_05_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "em_09"
              if answers[:em_09] == "Information available"
                if (answers[:em_09_table1_row1_number3].present? && (answers[:em_09_table1_row1_number3].to_f > 0)) && (answers[:em_09_table1_row6_number3].present? && (answers[:em_09_table1_row6_number3].to_f > 0)) && (answers[:em_04_table1_row1_number3].present? && (answers[:em_04_table1_row1_number3].to_f > 0))
                  idf_values = { :i => 0, :d => 40, :f => 20 }
                  if (answers[:em_09_table1_row1_number1].present? && (answers[:em_09_table1_row1_number1].to_f > 0)) && (answers[:em_09_table1_row6_number1].present? && (answers[:em_09_table1_row6_number1].to_f > 0)) && (answers[:em_04_table1_row1_number1].present? && (answers[:em_04_table1_row1_number1].to_f > 0))
                    trend_value = find_trend_type (answers[:em_09_table1_row1_number3].to_f / ((answers[:em_09_table1_row6_number3].to_f / 100) * answers[:em_04_table1_row1_number3].to_f)), (answers[:em_09_table1_row1_number1].to_f / ((answers[:em_09_table1_row6_number1].to_f / 100) * answers[:em_04_table1_row1_number1].to_f))
                    local_score += idf_values[trend_value.to_sym]
                  elsif (answers[:em_09_table1_row1_number2].present? && (answers[:em_09_table1_row1_number2].to_f > 0)) && (answers[:em_09_table1_row6_number2].present? && (answers[:em_09_table1_row6_number2].to_f > 0)) && (answers[:em_04_table1_row1_number2].present? && (answers[:em_04_table1_row1_number2].to_f > 0))
                    trend_value = find_trend_type (answers[:em_09_table1_row1_number3].to_f / ((answers[:em_09_table1_row6_number3].to_f / 100) * answers[:em_04_table1_row1_number3].to_f)), (answers[:em_09_table1_row1_number2].to_f / ((answers[:em_09_table1_row6_number2].to_f / 100) * answers[:em_04_table1_row1_number2].to_f))
                    local_score += idf_values[trend_value.to_sym]
                  end
                end
                if (answers[:em_09_table1_row4_number3].present? && (answers[:em_09_table1_row4_number3].to_f > 0)) && (answers[:em_09_table1_row6_number3].present? && (answers[:em_09_table1_row6_number3].to_f > 0)) && (answers[:em_04_table1_row1_number3].present? && (answers[:em_04_table1_row1_number3].to_f > 0))
                  idf_values = { :i => 40, :d => 0, :f => 20 }
                  if (answers[:em_09_table1_row4_number1].present? && (answers[:em_09_table1_row4_number1].to_f > 0)) && (answers[:em_09_table1_row6_number1].present? && (answers[:em_09_table1_row6_number1].to_f > 0)) && (answers[:em_04_table1_row1_number1].present? && (answers[:em_04_table1_row1_number1].to_f > 0))
                    trend_value = find_trend_type (answers[:em_09_table1_row4_number3].to_f / ((answers[:em_09_table1_row6_number3].to_f / 100) * answers[:em_04_table1_row1_number3].to_f)), (answers[:em_09_table1_row4_number1].to_f / ((answers[:em_09_table1_row6_number1].to_f / 100) * answers[:em_04_table1_row1_number1].to_f))
                    local_score += idf_values[trend_value.to_sym]
                  elsif (answers[:em_09_table1_row4_number2].present? && (answers[:em_09_table1_row4_number2].to_f > 0)) && (answers[:em_09_table1_row6_number2].present? && (answers[:em_09_table1_row6_number2].to_f > 0)) && (answers[:em_04_table1_row1_number2].present? && (answers[:em_04_table1_row1_number2].to_f > 0))
                    trend_value = find_trend_type (answers[:em_09_table1_row4_number3].to_f / ((answers[:em_09_table1_row6_number3].to_f / 100) * answers[:em_04_table1_row1_number3].to_f)), (answers[:em_09_table1_row4_number2].to_f / ((answers[:em_09_table1_row6_number2].to_f / 100) * answers[:em_04_table1_row1_number2].to_f))
                    local_score += idf_values[trend_value.to_sym]
                  end
                end
                if answers[:em_09_option1_checkbox1].present? && answers[:em_09_vb_option11_radio] == "Target set"
                  local_score += 10
                end
                if answers[:em_09_option1_checkbox2].present?
                  local_score += 10
                end
              elsif answers[:em_09] == "Not applicable"
                if answers[:em_09_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            when "sc_06"
              if answers[:sc_06] == "Information available"
                if answers[:sc_06_option1_checkbox1].present?
                  idf_values = { :i => 30, :d => 0, :f => 20 }
                  if answers[:sc_06_table1_row1_number3].present? && (answers[:sc_06_table1_row1_number3].to_f > 0)
                    if answers[:sc_06_table1_row1_number1].present? && (answers[:sc_06_table1_row1_number1].to_f > 0)
                      trend_value = find_trend_type answers[:sc_06_table1_row1_number3].to_f, answers[:sc_06_table1_row1_number1].to_f
                      local_score += idf_values[trend_value.to_sym]
                    elsif answers[:sc_06_table1_row1_number2].present? && (answers[:sc_06_table1_row1_number2].to_f > 0)
                      trend_value = find_trend_type answers[:sc_06_table1_row1_number2].to_f, answers[:sc_06_table1_row1_number2].to_f
                      local_score += idf_values[trend_value.to_sym]
                    end
                  end
                end
                if answers[:sc_06_option1_checkbox2].present?
                  idf_values = { :i => 30, :d => 0, :f => 20 }
                  if answers[:sc_06_table2_row1_number3].present? && (answers[:sc_06_table2_row1_number3].to_f > 0)
                    if answers[:sc_06_table2_row1_number1].present? && (answers[:sc_06_table2_row1_number1].to_f > 0)
                      trend_value = find_trend_type answers[:sc_06_table2_row1_number3].to_f, answers[:sc_06_table2_row1_number1].to_f
                      local_score += idf_values[trend_value.to_sym]
                    elsif answers[:sc_06_table2_row1_number2].present? && (answers[:sc_06_table2_row1_number2].to_f > 0)
                      trend_value = find_trend_type answers[:sc_06_table2_row1_number2].to_f, answers[:sc_06_table2_row1_number2].to_f
                      local_score += idf_values[trend_value.to_sym]
                    end
                  end
                end
                if answers[:sc_06_option1_checkbox3].present?
                  idf_values = { :i => 40, :d => 0, :f => 20 }
                  if answers[:sc_06_table3_row1_number3].present? && (answers[:sc_06_table3_row1_number3].to_f > 0)
                    if answers[:sc_06_table3_row1_number1].present? && (answers[:sc_06_table3_row1_number1].to_f > 0)
                      trend_value = find_trend_type answers[:sc_06_table3_row1_number3].to_f, answers[:sc_06_table3_row1_number1].to_f
                      local_score += idf_values[trend_value.to_sym]
                    elsif answers[:sc_06_table3_row1_number2].present? && (answers[:sc_06_table3_row1_number2].to_f > 0)
                      trend_value = find_trend_type answers[:sc_06_table3_row1_number2].to_f, answers[:sc_06_table3_row1_number2].to_f
                      local_score += idf_values[trend_value.to_sym]
                    end
                  end
                end
              elsif answers[:sc_06] == "Not applicable"
                if answers[:sc_06_vb_option4_radio] == "Reason provided are justified and it is not applicable"
                  non_countable_questions_count += 1
                  question_not_applicable_status = 1
                end
              end
            else
              puts "no matching case found in case of #{question_code}..."
            end
            category_total_score += local_score.round(2)
            QuestionnaireScore.find_or_create_by(company_user_id: @company_user_id, category_type: category_name, question_name: question_code, score: local_score.round(2), not_applicable_status: question_not_applicable_status)
          end

          if questions_count == non_countable_questions_count
            non_countable_categories_count += 1
            category_not_applicable_status = 1
            category_score = 0
          else
            category_score = (category_total_score / (questions_count - non_countable_questions_count).to_f).round(2)
          end

          total_categories_score += category_score
          case category_name
          when "cg", "rm", "be", "td"
            governance_aspect_score += category_score
            governance_aspect_na_count += category_not_applicable_status
          when "em", "bd", "pr"
            environmental_aspect_score += category_score
            environmental_aspect_na_count += category_not_applicable_status
          when "hr", "hc", "ohs", "csr", "sc"
            social_aspect_score += category_score
            social_aspect_na_count += category_not_applicable_status
          else
            # type code here
          end
          CategoryScore.find_or_create_by(company_user_id: @company_user_id, category_type: category_name, score: category_score, not_applicable_status: category_not_applicable_status)
        end
        company_score = (((governance_aspect_score / (4 - governance_aspect_na_count)) + (environmental_aspect_score / (3 - environmental_aspect_na_count)) + (social_aspect_score / (5 - social_aspect_na_count))) / 3).round(2)
        # company_score = (total_categories_score / (total_categories_count - non_countable_categories_count).to_f).round(2)
        CompanyScore.find_or_create_by(company_user_id: @company_user_id, total_score: total_categories_score.round(2), avg_score: company_score)
        User.company_users.find(@company_user_id).update(user_status: ApplicationRecord::ASSESSMENT_SCORE_GENERATED)
      end
    end

    def get_cg_05_sub_value value
      case value
      when 20..100
        return 50
      when 10..19.99
        return 30
      when 5..9.99
        return 20
      when 1..4.99
        return 10
      else
        return 0
      end
    end

    def find_trend_type year1, year2
      year_value = (((year1 - year2) / (year2).to_f) * 100)
      if year_value > 5
        return "i"
      elsif year_value < -5
        return "d"
      else
        return "f"
      end
    end

    def get_hr_06_sub_value value
      case value
      when 90..100
        return 20
      when 75..89.99
        return 10
      when 50..74.99
        return 5
      else
        return 0
      end
    end

    def get_hr_08_sub_value value
      case value
      when 40..100
        return 25
      when 20..39.99
        return 15
      when 10..19.99
        return 5
      else
        return 0
      end
    end

    def get_hr_09_sub_value value
      case value
      when 5..100
        return 25
      when 2..4.99
        return 15
      when 1..1.99
        return 5
      else
        return 0
      end
    end

    def get_hr_10_sub_value value
      case value
      when 75..100
        return 25
      when 50..74.99
        return 15
      when 25..49.99
        return 10
      when 1..24.99
        return 5
      else
        return 0
      end
    end

    def get_hc_02_03_sub_value value
      case value
      when 80..100
        return 25
      when 50..79.99
        return 15
      when 20..49.99
        return 10
      when 6..19.99
        return 5
      else
        return 0
      end
    end

    def get_local_score (question_code, answers, options_score)
      temp_local_score = 0
      (1..9).each do |option|
        if answers[(question_code + '_option1_checkbox' + option.to_s).to_sym].present?
          temp_local_score += options_score[option - 1]
        end
      end
      return temp_local_score
    end

    def get_validate_c_box_add_score (question_code, answers, options_score)
      validate_c_box_add_score = 0
      (1..6).each do |option|
        if answers[(question_code + '_vb_option1_checkbox' + option.to_s).to_sym].present?
          validate_c_box_add_score += options_score[option - 1]
        end
      end
      return validate_c_box_add_score
    end

  end
end