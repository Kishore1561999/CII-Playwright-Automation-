# frozen_string_literal: true

module ExcelAnalyticsCalculationHelper
    include ActiveSupport::NumberHelper
  
    def calculate_average(total_answers_data, question_name, company_data, qid)
      result = extract_numeric_answers(total_answers_data, question_name).reject(&:nil?)
      return { average: '0', maximum: '0', minimum: '0' } if result.empty?
      if qid == 'PB-05' || qid == 'PB-06' || qid == 'PB-07' || qid == 'PB-09'
        name_value = 'Information available'
      elsif qid == 'PB-13'
        name_value = 'LCA conducted'
      else
        name_value = 'information_available'
      end
      total_count = 0
      sumvalue = 0
      allvalues = []
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        if user_answers[question_name].present?
          if user_answers[question_name].to_f >= 0 && user_answers[qid.downcase.underscore] == name_value
            total_count += 1
            sumvalue += user_answers[question_name].to_f
            allvalues << user_answers[question_name].to_f
          end
        end
      end
      if total_count > 0
        average = (sumvalue / total_count).round(2)
      else
        average = 0
      end
      #max = result.max
      #min = result.reject { |value| value <= 0 }.min || 0 # Exclude zeros from minimum calculation
      max = allvalues.max || 0
      min = allvalues.min || 0
      { average: average, maximum: max.round(2), minimum: min.round(2), question_name: question_name, size: total_count, sum: sumvalue, allvalues: allvalues, qid: qid  }
    end
  
    def calculate_average_table_data(total_answers_data, question_name, company_data, qid)
      result = extract_numeric_answers(total_answers_data, question_name).reject(&:nil?)
      return { average: '0', maximum: '0', minimum: '0' } if result.empty?
      if qid == 'PB-05' || qid == 'PB-06' || qid == 'PB-07' || qid == 'PB-09'
        name_value = 'Information available'
      elsif qid == 'PB-13'
        name_value = 'LCA conducted'
      else
        name_value = 'information_available'
      end
      total_count = 0
      sumvalue = 0
      allvalues = []
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        if user_answers[question_name].present?
          if user_answers[question_name].to_f >= 0 && user_answers[qid.downcase.underscore] == name_value
            total_count += 1
            sumvalue += user_answers[question_name].to_f
            allvalues << user_answers[question_name]
          end
        end
      end
      if total_count > 0
        average = (sumvalue / total_count)
      else
        average = 0
      end
      # max = result.max
      # min = result.reject { |value| value <= 0 }.min || 0 # Exclude zeros from minimum calculation
      max = allvalues.max || 0
      min = allvalues.min || 0
      { average: average, maximum: max, minimum: min, question_name: question_name, size: total_count, sum: sumvalue, allvalues: allvalues, qid: qid  }
    end
  
    def calculate_percentage(total_answers_data, question_data, q_id)
      result = extract_answers_for_question(total_answers_data, q_id)
      answered_result = result.select { |r| r == question_data['label'] }
      percentage = calculate_percentage_from_counts(answered_result.count, total_answers_data.count)
      percentage.to_f.round(2)
    end
  
    def calculate_lca_percentage(total_answers_data, question_name, q_id)
      count_option_1 = 0
      count_option_2 = 0
      count_option_3 = 0
      count_option_4 = 0
      count_option_5 = 0
      total_count = total_answers_data.size
  
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        if user_answers['pb_13'] == 'LCA conducted'
          count_option_1 += 1
        end
        if user_answers['pb_13'] == 'No LCA conducted'
          count_option_2 += 1
        end
        if user_answers['pb_13'] == 'Indicator is not relevant for the industry'
          count_option_3 += 1
        end
        if user_answers['pb_13'] == 'No information'
          count_option_4 += 1
        end
        if user_answers['pb_13_option_checkbox2'] == 'Results communicated externally'
          count_option_5 += 1
        end
      end
      {
        percent_1: calculate_percentage_from_counts(count_option_1, total_count),
        percent_2: calculate_percentage_from_counts(count_option_2, total_count),
        percent_3: calculate_percentage_from_counts(count_option_3, total_count),
        percent_4: calculate_percentage_from_counts(count_option_4, total_count),
        percent_5: calculate_percentage_from_counts(count_option_5, total_count)
      }
    end
  
    def calculate_threeoptions_choosen_percentage(total_answers_data, question_name, q_id)
      count_option_1 = 0
      count_option_2 = 0
      count_option_3 = 0
  
      total_companies = total_answers_data.size
  
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        next if user_answers.nil?
        general_option = user_answers["pb_19"]
      
        count_option_1 += 1 if general_option == "information_available"
        count_option_2 += 1 if general_option == "Company does not have OHS management system in place."
        count_option_3 += 1 if general_option == "No clear information"
      end
  
      {
        percent_option_1: calculate_percentage_from_counts(count_option_1, total_companies),
        percent_option_2: calculate_percentage_from_counts(count_option_2, total_companies),
        percent_option_3: calculate_percentage_from_counts(count_option_3, total_companies)
      }
  
    end
  
    def calculate_total_value(total_answers_data, question_name, company_data)
      result = extract_numeric_answers(total_answers_data, question_name)
      
      total = result.sum.to_i
      total
    end
  
    def calculate_percentage_seventhquestion(total_answers_data, question_data, q_id)
      if q_id == 'PB-07'
        qvalue = 'Information available'
      else
        qvalue = 'information_available'
      end
      relevant_responses = extract_relevant_responses(total_answers_data, q_id, qvalue)
      if q_id != 'PB-14'
        return "0%" if relevant_responses.empty?
      end
  
      sub_option_count = relevant_responses.count do |ta|
        ta.user_answers.any? { |key, value| key.include?(q_id.downcase.underscore) && value == question_data['label'] }
      end
      
      count_option_1 = 0
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        if user_answers['pb_35'] == 'information_available'
          if user_answers['pb_35_option_radio'] == 'Internal Policy'
            count_option_1 += 1
          end
          if user_answers['pb_35_option_radio'] == 'Publicly available Policy'
            count_option_1 += 1
          end
          if user_answers['pb_35_option_radio'] == 'Company reported to have no such policy'
            count_option_1 += 1
          end
       end
      end
      
      if q_id == 'PB-14'
        total_companies = total_answers_data.size
        not_verified = relevant_responses.count - sub_option_count
        {
        percent_option_1: calculate_percentage_from_counts(sub_option_count, relevant_responses.count),
        percent_option_2: calculate_percentage_from_counts(not_verified, relevant_responses.count)
        }
      elsif q_id == 'PB-35'
        percentage = calculate_percentage_from_counts(sub_option_count, count_option_1)
         percentage.to_f.round(2)
      else
        percentage = calculate_percentage_from_counts(sub_option_count, relevant_responses.count)
         percentage.to_f.round(2)
      end
      
    end
  
    def calculate_optiontwo_choosen_percentage(total_answers_data, question_data, q_id, qvalue)
      if q_id == 'PB-20'
        option_value = 'Lost Time Injury Frequency Rate'
      end
      relevant_responses = extract_relevant_responses_for_option(total_answers_data, q_id, option_value)
      return "0%" if relevant_responses.empty?
  
      sub_option_count = relevant_responses.count do |ta|
        ta.user_answers.any? { |key, value| key.include?(q_id.downcase.underscore) && value == qvalue }
      end
  
      percentage = calculate_percentage_from_counts(sub_option_count, relevant_responses.count)
      percentage.to_f.round(2)
    end
  
    def find_two_values(total_answers_data, question_name, company_data)
      categories = {
        'sexual harassment' => 'pb_25_table_row1_number1',
        'discrimination' => 'pb_25_table_row2_number1',
        'child labor' => 'pb_25_table_row3_number1',
        'forced labor' => 'pb_25_table_row4_number1',
        'wages' => 'pb_25_table_row5_number1',
        'others' => 'pb_25_table_row6_number1'
      }
  
      category_totals = Hash.new(0)
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        categories.each do |category, key|
          value = user_answers[key]
          category_totals[category] += value.to_i unless value.nil? || value.empty?
        end
      end
  
      categories.keys.each do |category|
        category_totals[category] = 0 unless category_totals.key?(category)
      end
  
      sorted_totals = category_totals.sort_by { |category, total| [-total, total == 0 ? 1 : 0] }.to_h
      sorted_totals
    end
  
    def calculate_trend(total_answers_data, question_name, company_data, q_id, position)
      answer_keys = determine_answer_keys(q_id, position)
      relevant_responses = extract_relevant_responses_with_keys(total_answers_data, answer_keys)
      trends = relevant_responses.map do |response|
        value1 = response.user_answers[answer_keys[0]].to_f
        value2 = response.user_answers[answer_keys[1]].to_f
        value1 - value2
      end
  
      positive_trends_count = trends.count { |trend| trend > 0 }
      percentage = calculate_percentage_from_counts(positive_trends_count, relevant_responses.count)
      percentage.to_f.round(2)
    end
  
    def calculate_investing(total_answers_data, question_name, company_data, q_id, position)
      answer_key = determine_answer_key_for_investing(q_id, position)
      relevant_responses = extract_relevant_responses_with_key(total_answers_data, answer_key)
      invest_values = relevant_responses.map { |response| response.user_answers[answer_key].to_f }.select { |value| value > 0 }
      
      percentage = calculate_percentage_from_counts(invest_values.count, relevant_responses.count)
      percentage.to_f.round(2)
    end
  
    def calculate_commitment(total_answers_data, question_name, company_data, q_id, position)
      answer_key = determine_answer_key_for_commitment(q_id, position)
      relevant_responses = extract_relevant_responses_with_key(total_answers_data, answer_key)
      commitment_values = relevant_responses.map { |response| response.user_answers[answer_key].to_f }.count { |value| value == 100 }
  
      percentage = calculate_percentage_from_counts(commitment_values, relevant_responses.count)
      percentage.to_f.round(2)
    end
  
    def calculate_ethics(total_answers_data, question_name, q_id)
      count_option_a = 0
      count_option_b = 0
      count_both_a_and_b = 0
      count_option_2 = 0
      count_option_3 = 0
  
      total_companies = total_answers_data.size
  
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        next if user_answers.nil?
  
        option_a = user_answers["pb_06_option1_checkbox1"]
        option_b = user_answers["pb_06_option2_checkbox2"]
        general_option = user_answers["pb_06"]
  
        if general_option == 'Information Available'
          if option_a.present? && option_b.present?
            count_both_a_and_b += 1
          elsif option_a.present?
            count_option_a += 1
          elsif option_b.present?
            count_option_b += 1
          end
        end
        count_option_2 += 1 if general_option == "No such policies in place"
        count_option_3 += 1 if general_option == "No clear information"
      end
  
      {
        percent_option_a: calculate_percentage_from_counts(count_option_a, total_companies),
        percent_option_b: calculate_percentage_from_counts(count_option_b, total_companies),
        percent_both_a_and_b: calculate_percentage_from_counts(count_both_a_and_b, total_companies),
        percent_option_2: calculate_percentage_from_counts(count_option_2, total_companies),
        percent_option_3: calculate_percentage_from_counts(count_option_3, total_companies)
      }
    end
  
    def calculate_coc(total_answers_data, question_name, q_id)
      count_radio_option = 0
      count_radio_option2 = 0
      count_checkbox_option = 0
  
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        next if user_answers.nil?
  
        if user_answers["pb_06_option1_checkbox1"].present?
          general_option = user_answers["pb_06_option1_radio"]
  
          count_checkbox_option += 1
          count_radio_option += 1 if general_option == "Internal Policy"
          count_radio_option2 += 1 if general_option == "Publicly available Policy"
        end
      end
      {
        option1: calculate_percentage_from_counts(count_radio_option, count_checkbox_option),
        option2: calculate_percentage_from_counts(count_radio_option2, count_checkbox_option)
      }
    end
  
    def calculate_empcoc(total_answers_data, question_name, q_id)
      count_radio_option = 0
      count_radio_option2 = 0
      count_checkbox_option = 0
  
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        next if user_answers.nil?
  
        if user_answers["pb_06_option2_checkbox2"].present?
          general_option = user_answers["pb_06_option2_radio"]
          count_checkbox_option += 1
          count_radio_option += 1 if general_option == "Internal Policy"
          count_radio_option2 += 1 if general_option == "Publicly available Policy"
        end
      end
  
      {
        option1: calculate_percentage_from_counts(count_radio_option, count_checkbox_option),
        option2: calculate_percentage_from_counts(count_radio_option2, count_checkbox_option)
      }
    end
  
    def calculate_percentage_for_independent_assessment(total_answers_data, question_name, q_id, name)
      count_checkbox_option = 0
      denominator_count = 0
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        next if user_answers.nil?
  
        if user_answers[q_id.downcase.underscore] == 'information_available'
          if user_answers[name].to_f >= 0
            denominator_count += 1
            if user_answers[question_name].present?
              count_checkbox_option += 1
            end
          end
        end
      end
      if denominator_count > 0
        percentage = calculate_percentage_from_counts(count_checkbox_option, denominator_count)
        "#{percentage.to_f.round(2)}%"
      else
        percentage = 0
      end

    end

    def calculate_percentage_for_third_part(total_answers_data, question_name, q_id)
      count_checkbox_option = 0
      denominator_count = 0
      total_answers_data.each do |answer|
        user_answers = answer.user_answers
        next if user_answers.nil?
  
        if user_answers[q_id.downcase.underscore] == 'information_available'
            denominator_count += 1
            if user_answers[question_name].present?
              count_checkbox_option += 1
            end
        end
      end
      if denominator_count > 0
        percentage = calculate_percentage_from_counts(count_checkbox_option, denominator_count)
        "#{percentage.to_f.round(2)}%"
      else
        percentage = 0
      end

    end

    private
  
    def extract_numeric_answers(total_answers_data, question_name)
      total_answers_data.map { |answer| answer.user_answers[question_name]&.to_f }.compact
    end
  
    def extract_answers_for_question(total_answers_data, q_id)
      q_id_under = q_id.downcase.underscore
      total_answers_data.flat_map { |ta| ta.user_answers.select { |key, _value| key.include?(q_id_under) }.values }
    end
  
    def extract_relevant_responses(total_answers_data, q_id, value)
      q_id_under = q_id.downcase.underscore
      total_answers_data.select do |ta|
        ta.user_answers.any? { |key, val| key.include?(q_id_under) && val == value }
      end
    end
  
    def extract_relevant_responses_for_option(total_answers_data, q_id, qvalue)
      q_id_under = q_id.downcase.underscore
      answer_keys = {
        'pb_28' => 'pb_28_table_row1_number1',
        'pb_29' => 'pb_29_table_row1_number1',
        'pb_30' => 'pb_30_table_row1_number1',
        'pb_31' => 'pb_31_table_row1_number1',
        'pb_32' => 'pb_32_option1_checkbox1'
      }
      key_to_check = answer_keys[q_id_under]
  
      if key_to_check
        total_answers_data.select { |ta| ta.user_answers[key_to_check].present? }
      else
        extract_relevant_responses(total_answers_data, q_id, qvalue)
      end
    end
  
    def extract_relevant_responses_with_keys(total_answers_data, keys)
      total_answers_data.select do |ta|
        keys.all? { |key| ta.user_answers[key].present? }
      end
    end
  
    def extract_relevant_responses_with_key(total_answers_data, key)
      total_answers_data.select do |ta|
        ta.user_answers[key].present?
      end
    end
  
    def calculate_percentage_from_counts(partial_count, total_count)
      return "0%" if total_count.zero?
  
      percentage = (partial_count.to_f / total_count * 100).round(2)
      "#{percentage}%"
    end
  
    def determine_answer_keys(q_id, position)
      if position == 'R_D'
        { 'pb_11' => ['pb_11_table_row1_number1', 'pb_11_table_row1_number2'] }
      else
        { 'pb_11' => ['pb_11_table_row2_number1', 'pb_11_table_row2_number2'] }
      end[q_id.downcase.underscore]
    end
  
    def determine_answer_key_for_investing(q_id, position)
      if position == 'R_D'
        { 'pb_11' => 'pb_11_table_row1_number1' }
      else
        { 'pb_11' => 'pb_11_table_row2_number1' }
      end[q_id.downcase.underscore]
    end
  
    def determine_answer_key_for_commitment(q_id, position)
      if position == 'R_D'
        { 'pb_11' => 'pb_11_table_row1_number1' }
      else
        { 'pb_11' => 'pb_11_table_row2_number1' }
      end[q_id.downcase.underscore]
    end
  
    def pb_questions
      pb_questions = ['PB-03', 'PB-05', 'PB-06', 'PB-07', 'PB-08', 'PB-09', 'PB-10', 'PB-14', 'PB-15', 'PB-19', 'PB-22', 'PB-26', 'PB-27', 'PB-35']
    end
  
    def pbtwo_buttons(answers, average)
      answer = answers.to_f
      average = average.to_f
      if answers.present?
      return 'green-hexagon' if answer && answer > average.round
      return 'red-hexagon' if answer && answer < average.round
      return 'yellow-hexagon' if answer && answer == average.round
      else
      return 'grey-hexagon'
      end
    end
  
  end
  