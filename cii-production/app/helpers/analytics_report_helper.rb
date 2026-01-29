# frozen_string_literal: true

module AnalyticsReportHelper
    include ActiveSupport::NumberHelper

    def download_sector_specific_excel_data(sector_specific_data, template, sector_name, questions)
      filename = "#{sector_name}_#{Date.today.strftime('%d-%m-%Y')}.xlsx"
      respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
          render template: template
        end
        format.html { render :export_excel }
      end
    end

    def download_general_specific_excel_data(sector_specific_data, template, sector_name, questions)
      filename = "General Specific Report_#{Date.today.strftime('%d-%m-%Y')}.xlsx"
      respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
          render template: template
        end
        format.html { render :export_excel }
      end
    end

    def average_analytics(sector_specific_data, questions, qid)
      @chart_data = []
      @get_question = find_question(qid)
      @table_rows = find_table_rows(@get_question)
      case qid
      when 'PB-01', 'PB-04', 'PB-09', 'PB-11', 'PB-14', 'PB-16', 'PB-17', 'PB-18', 'PB-21', 'PB-22', 'PB-23', 'PB-24', 'PB-25', 'PB-27', 'PB-28', 'PB-29', 'PB-30', 'PB-31', 'PB-32', 'PB-34'
        @table_rows = find_table_rows(@get_question)
        @table_rows.map do |sub|
          if sub['name'].present?
            if qid == 'PB-28' || qid == 'PB-29' || qid == 'PB-30' || qid == 'PB-31' 
              @chart_data << calculate_average_table_data(sector_specific_data, sub['name'], '', qid)
            else
              @chart_data << calculate_average(sector_specific_data, sub['name'], '', qid)
            end
          end
        end
    
        if qid == 'PB-11'
          @valueelven = []
          row_name_to_category = {
            'pb_11_table_row1_number1' => 'R_D',
            'pb_11_table_row2_number1' => 'capex'
          }
        
          @table_rows.each do |sub|
            category = row_name_to_category[sub['name']]
            next unless category
        
            @valueelven << {
              trend: calculate_trend(sector_specific_data, sub['name'], '', qid, category),
              investing: calculate_investing(sector_specific_data, sub['name'], '', qid, category),
              commitment: calculate_commitment(sector_specific_data, sub['name'], '', qid, category)
            }
          end
        end
    
        @get_question.options.each do |question_option|
          if question_option['sub_answers'].present?
            question_option['sub_answers'].each do |sub_answer|
              valid_questions = ['PB-24', 'PB-28', 'PB-29', 'PB-30', 'PB-31', 'PB-14']
              if valid_questions.include?(qid)
                @chart_data << {
                  percentage: calculate_percentage_seventhquestion(sector_specific_data, sub_answer, qid)
                }
              end
            end
          end
        end
      when 'PB-06'
        @valuesix = @get_question.options.each_with_object([]) do |question_option, valuesix|
          if question_option['sub_answers'].present?
            question_option['sub_answers'].each do |sub_answer|
              valuesix << {
                ethics: calculate_ethics(sector_specific_data, sub_answer['name'], qid)
              }
              if sub_answer['sub_answers']
                sub_answer['sub_answers'].each do |subanswer_2|
                  if %w[pb_06_option1_radio pb_06_option2_radio].include?(subanswer_2['name']) && subanswer_2['label'] == 'Internal Policy'
                    valuesix << {
                      coc: calculate_coc(sector_specific_data, subanswer_2['name'], qid),
                      empcoc: calculate_empcoc(sector_specific_data, subanswer_2['name'], qid)
                    }
                  end
                end
              end
            end
          end
        end
    
      when 'PB-02', 'PB-03', 'PB-05', 'PB-07', 'PB-08', 'PB-10', 'PB-12', 'PB-15', 'PB-19', 'PB-26', 'PB-33', 'PB-35'
        @value = @get_question.options.each_with_object([]) do |question_option, value|
          if question_option['sub_answers'].present?
            question_option['sub_answers'].each do |sub_answer|
              if qid == 'PB-19'
                value << {
                  graphone: calculate_threeoptions_choosen_percentage(sector_specific_data, sub_answer, qid),
                  graphtwo: calculate_percentage_seventhquestion(sector_specific_data, sub_answer, qid)
                }
              elsif qid == 'PB-02' || qid == 'PB-03' || qid == 'PB-12' || qid == 'PB-33'
                value << {
                  values: calculate_average(sector_specific_data, sub_answer['name'], '', qid)
                }
              elsif %w[PB-07 PB-08 PB-10 PB-15 PB-26 PB-35].include?(qid)
                value << {
                  percentage: calculate_percentage_seventhquestion(sector_specific_data, sub_answer, qid)
                }
              else
                value << {
                  percentage: calculate_percentage(sector_specific_data, sub_answer, qid)
                }
              end
            end
          end
        end
    
      when 'PB-13'
        @percentage_names = ['pb_13_percentage_1', 'pb_13_percentage_2']
        @valuethirteen = []
        @percentage_names.each do |names|
          @valuethirteen << {
              average: calculate_average(sector_specific_data,names, '', qid)
          }
        end   
        @valuethirteen << {
            lca_average: calculate_lca_percentage(sector_specific_data, '', qid)
          }
        
      when 'PB-20'
        @valuetwenty = find_values(@get_question, qid, sector_specific_data)
      end
    
      {
        company_data: @chart_data,
        percentage: @value,
        question: qid,
        valuesix: @valuesix,
        valuethirteen: @valuethirteen,
        valuetwenty: @valuetwenty,
        valueelven: @valueelven
      }
    end
    
   
  
    def find_table_rows(question)
      return [] unless question
  
      question.options.each_with_object([]) do |question_option, table_rows|
        next unless question_option['sub_answers']
  
        question_option['sub_answers'].each do |sub_answer|
          next unless sub_answer['has_table']
  
          sub_answer['table_data'].each do |table_data|
            table_data.each do |table_row|
                table_rows << table_row
            end
          end
        end
      end
    end
  
    def find_values(question, q_id, sector_specific_data)
      return [] unless question
      @value = []
      question.options.each_with_object([]) do |question_option, table_rows|
        next unless question_option['sub_answers']
    
        question_option['sub_answers'].each do |sub_answer|
            next unless sub_answer['has_table']
    
            sub_answer['table_data'].each do |table_data|
              table_data.each do |table_row|
                if relevant_table_row?(table_row['name'])
                  @value << {
                    numbers: calculate_average(sector_specific_data, table_row['name'], '', q_id)
                  }
                end
              end
            end
            sub_answer['sub_answers'].each do |sub| 
                if sub['name'] == 'pb_20_option11_checkbox1' || sub['name'] == 'pb_20_option21_checkbox1'
                  @value << {
                    percentage: calculate_optiontwo_choosen_percentage(sector_specific_data, sub['name'], q_id, 'Data has been assured/verified by third party')
                  }
                end
            end 
        end
      end
  
    end
  
    def relevant_table_row?(name)
      %w[
        pb_20_table1_row1_number1 pb_20_table1_row1_number2
        pb_20_table1_row2_number1 pb_20_table1_row2_number2
        pb_20_table2_row1_number1 pb_20_table2_row2_number1
      ].include?(name)
    end
    
    def twentyfifth_analytics(sector_specific_data, questions, qid)
      @chart_data = []
      @get_question = find_question(qid)
      @table_rows = find_table_rows(@get_question)
      @table_rows.map do |sub|
        if sub['name'].present?
          @chart_data << find_two_values(sector_specific_data, sub['name'], '')
        end
      end
      @chart_data
    end

    def thirtytwo_analytics(sector_specific_data, questions, qid)
      results = []
      results1 = []
      @get_question = find_question(qid)
      @table_rows = find_table_rows(@get_question)
      @table_rows.map do |sub|
        if sub['name'].present?
          results << calculate_average(sector_specific_data, sub['name'], '', qid)
          results1 << calculate_total_value(sector_specific_data, sub['name'], '')
        end
      end
      {
        results: results,
        results1: results1,
      }
    end

    def find_question(question)
      PeerBenchmarkingQuestionnaire.find_by(question_id: question)
    end
    
    def process_user_answers(user_answers)
      pb_05 = user_answers['pb_05'] == 'No information available' ? user_answers['pb_05'] : '-'
  
      pb_06_1 = pb_06_2 = pb_07 = pb_06_checkbox_1 = pb_06_checkbox_2 = pb_06_checkbox_2_1 = pb_06_checkbox_2_1 = pb_19 = '-'
  
      case user_answers['pb_06']
      when 'No such policies in place'
        pb_06_1 = user_answers['pb_06']
      when 'No clear information'
        pb_06_2 = user_answers['pb_06']
      else
        pb_06_1 = pb_06_2 = '-'
      end

      case user_answers['pb_06_option1_radio']
      when 'Internal Policy'
        pb_06_checkbox_1 = user_answers['pb_06_option1_radio']
      when 'Publicly available Policy'
        pb_06_checkbox_2 = user_answers['pb_06_option1_radio']
      else
        pb_06_checkbox_1 = pb_06_checkbox_2 = '-'
      end

      case user_answers['pb_06_option2_radio']
      when 'Internal Policy'
        pb_06_checkbox_2_1 = user_answers['pb_06_option2_radio']
      when 'Publicly available Policy'
        pb_06_checkbox_2_2 = user_answers['pb_06_option2_radio']
      else
        pb_06_checkbox_2_1 = pb_06_checkbox_2_2 = '-'
      end
  
      pb_07 = user_answers['pb_07'] == 'No clear information' ? user_answers['pb_07'] : '-'
  
      pb_07_1, pb_07_2, pb_07_3 = '-', '-', '-'
      case user_answers['pb_07_option_radio']
      when 'Internal Policy'
        pb_07_1 = 'Internal Policy'
      when 'Publicly available Policy'
        pb_07_2 = 'Publicly available Policy'
      when 'No such policy in place'
        pb_07_3 = 'No such policy in place'
      end
  
      pb_08_1, pb_08_2, pb_08_3, pb_08_4, pb_08_5, pb_08_6, pb_08_7 = '-', '-', '-', '-', '-', '-', '-'
      case user_answers['pb_08_option_radio']
      when 'Dedicated Board ESG/Sustainability committee'
        pb_08_1 = 'Dedicated Board ESG/Sustainability committee'
      when 'ESG/Sustainability function part of other board committee'
        pb_08_2 = 'ESG/Sustainability function part of other board committee'
      when 'No board level committee, but CSO or dedicated executive director for sustainability issues'
        pb_08_3 = 'No board level committee, but CSO or dedicated executive director for sustainability issues'
      when 'No dedicated board committee, but MD/CEO/CFO/COO or any other executive with multiple responsibilities is also responsible for sustainability issues'
        pb_08_4 = 'No dedicated board committee, but MD/CEO/CFO/COO or any other executive with multiple responsibilities is also responsible for sustainability issues'
      when 'No dedicated board committee but a Non-executive director is responsible for sustainability issues'
        pb_08_5 = 'No dedicated board committee but a Non-executive director is responsible for sustainability issues'
      when 'No board level, only operational level ESG committee/Individual'
        pb_08_6 = 'No board level, only operational level ESG committee/Individual'
      when 'Company reports to have not defined the responsibility in BRSR'
        pb_08_7 = 'Company reports to have not defined the responsibility in BRSR'
      end
  
      pb_10_1, pb_10_2, pb_10_3 = '-', '-', '-'
      case user_answers['pb_10_option_radio']
      when 'Internal Policy'
        pb_10_1 = 'Internal Policy'
      when 'Publicly available Policy'
        pb_10_2 = 'Publicly available Policy'
      when 'Company reported to have no such policy'
        pb_10_3 = 'Company reported to have no such policy'
      end
      
      pb_12 = '-'
      case user_answers['pb_12']
      when 'information_available'
        pb_12 = user_answers['pb_12_option_number']
      when 'No clear information'
        pb_12 = '-'
      when 'Indicator is not relevant for the industry'
        pb_12 = '-'
      end

      pb_13_1, pb_13_2 = '-', '-'
      case user_answers['pb_13']
      when 'No LCA conducted'
        pb_13_1 = 'No LCA conducted'
      when 'Indicator is not relevant for the industry'
        pb_13_2 = 'Indicator is not relevant for the industry'
      end
      
      pb_14_checkbox = user_answers['pb_14_option1_checkbox1'].present? ? 'True' : 'False'

      pb_15_1, pb_15_2, pb_15_3 = '-', '-', '-'
      case user_answers['pb_15_option_radio']
      when 'Internal Policy'
        pb_15_1 = 'Internal Policy'
      when 'Publicly available Policy'
        pb_15_2 = 'Publicly available Policy'
      when 'Company has no such policy in place'
        pb_15_3 = 'Company has no such policy in place'
      end
  
      pb_19_1, pb_19_2, pb_19_3, pb_19_4 = '-', '-', '-', '-'
      case user_answers['pb_19_option_radio']
      when 'Company has OHS management system but no further details'
        pb_19_1 = 'Company has OHS management system but no further details'
      when 'Company has OHS management system & process to identify risks'
        pb_19_2 = 'Company has OHS management system & process to identify risks'
      when 'Company has OHS management system and process to report risk'
        pb_19_3 = 'Company has OHS management system and process to report risk'
      when 'Company has OHS management system, process to identify & process to report risks'
        pb_19_4 = 'Company has OHS management system, process to identify & process to report risks'
      end
  
      pb_19 = user_answers['pb_19'] == 'Company does not have OHS management system in place.' ? user_answers['pb_19'] : '-'
      
      pb_20_1 = user_answers['pb_20_option11_checkbox1'].present? ? 'True' : 'False'
      pb_20_2 = user_answers['pb_20_option21_checkbox1'].present? ? 'True' : 'False'

      pb_24 = user_answers['pb_24_option1_checkbox'].present? ? 'True' : 'False'

      pb_26_1, pb_26_2 = '-', '-'
      case user_answers['pb_26_option_radio']
      when 'Yes, it does'
        pb_26_1 = 'Yes, it does'
      when 'No it doesn’t'
        pb_26_2 = 'No it doesn’t'
      end
      
      pb32 = user_answers['pb_32_option11_checkbox1'].present? ? 'True' : 'False'

      pb33 = '-'
      case user_answers['pb_33']
      when 'information_available'
        pb33 = user_answers['pb_33_option_number']
      when 'No clear information'
        pb33 = ''
      end

      pb_35_1, pb_35_2, pb_35_3 = '-', '-', '-'
      case user_answers['pb_35_option_radio']
      when 'Internal Policy'
        pb_35_1 = 'Internal Policy'
      when 'Publicly available Policy'
        pb_35_2 = 'Publicly available Policy'
      when 'Company reported to have no such policy'
        pb_35_3 = 'Company reported to have no such policy'
      end
  
      pb_28_checkbox = user_answers['pb_28_option_checkbox'].present? ? 'True' : 'False'
      pb_29_checkbox = user_answers['pb_29_option_checkbox'].present? ? 'True' : 'False'
      pb_30_checkbox = user_answers['pb_30_option_checkbox'].present? ? 'True' : 'False'
      pb_31_checkbox = user_answers['pb_31_option_checkbox'].present? ? 'True' : 'False'
  
      {
        pb_05: pb_05,
        pb_06_1: pb_06_1,
        pb_06_2: pb_06_2,
        pb_06_checkbox_1: pb_06_checkbox_1,
        pb_06_checkbox_2: pb_06_checkbox_2,
        pb_06_checkbox_2_1: pb_06_checkbox_2_1,
        pb_06_checkbox_2_2: pb_06_checkbox_2_2,
        pb_07: pb_07,
        pb_07_1: pb_07_1,
        pb_07_2: pb_07_2,
        pb_07_3: pb_07_3,
        pb_08_1: pb_08_1,
        pb_08_2: pb_08_2,
        pb_08_3: pb_08_3,
        pb_08_4: pb_08_4,
        pb_08_5: pb_08_5,
        pb_08_6: pb_08_6,
        pb_08_7: pb_08_7,
        pb_10_1: pb_10_1,
        pb_10_2: pb_10_2,
        pb_10_3: pb_10_3,
        pb_12: pb_12,
        pb_13_1: pb_13_1,
        pb_13_2: pb_13_2,
        pb_14: pb_14_checkbox,
        pb_15_1: pb_15_1,
        pb_15_2: pb_15_2,
        pb_15_3: pb_15_3,
        pb_19_1: pb_19_1,
        pb_19_2: pb_19_2,
        pb_19_3: pb_19_3,
        pb_19_4: pb_19_4,
        pb_19: pb_19,
        pb_20_1: pb_20_1,
        pb_20_2: pb_20_2,
        pb_24: pb_24,
        pb_26_1: pb_26_1,
        pb_26_2: pb_26_2,
        pb32: pb32,
        pb33: pb33,
        pb_35_1: pb_35_1,
        pb_35_2: pb_35_2,
        pb_35_3: pb_35_3,
        pb_28_checkbox: pb_28_checkbox,
        pb_29_checkbox: pb_29_checkbox,
        pb_30_checkbox: pb_30_checkbox,
        pb_31_checkbox: pb_31_checkbox
      }
    end

    def format_value(value)
      value == '' ? 'NA' : value
    end

    def format_values_pb01(average, maximum, minimum)
      if average == ''
        ['NA', 'NA', 'NA']
      else
        [average, maximum, minimum]
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
  