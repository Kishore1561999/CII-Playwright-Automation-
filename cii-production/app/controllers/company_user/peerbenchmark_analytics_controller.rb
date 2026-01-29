class CompanyUser::PeerbenchmarkAnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_variables, only: [:analytics_dashboard, :analytics_calculation, :analytics_graphs, :fetch_analytics_graphs_data, :find_table_rows]
  
  include ApplicationHelper
  include AnalyticsCalculationHelper

  def analytics_graphs
    # The @questions instance variable is set in the set_variables before_action
    if @current_user_answer.present?
      if @user_answers.pdfreportfile.present? && 
        @fileName = @user_answers.pdfreportfile.created_at
        @year = @fileName.strftime('%Y')
      else
        @year = Time.now.year
      end
    else
      @year = Time.now.year
    end
    @cross_industry = @total_answers_data.size
    @sector_industry = @total_answers_data_sectorwise.size
    @total_questions = @questions.size
    questions = ['PB-02', 'PB-28', 'PB-29', 'PB-30', 'PB-31', 'PB-33']
    @value = []
    @data = []
    @answers = []
     
    questions.each do |q_id|
      if pb_questions.include?(q_id)
        companies_data = @total_answers_data
      else
        companies_data = @total_answers_data_sectorwise
      end
      @get_question = find_question(q_id)
  
      @get_question.options.each do |question_option|
        next unless question_option['sub_answers'].present?
  
        question_option['sub_answers'].each do |sub_answer|
          if q_id == 'PB-02' || q_id == 'PB-33'
            @value << {
              total: calculate_total_value(companies_data, sub_answer['name'], @current_user_answer),
              maximum: calculate_average(companies_data, sub_answer['name'], @current_user_answer, q_id)
            }
            answervalue = @current_user_answer[sub_answer['name']]
            @answers << {
              ans: @current_user_answer[sub_answer['name']],
              name: sub_answer['name'],
              checkbox_name: @current_user_answer[q_id.downcase.underscore],
              orignalans: @current_user_answer[sub_answer['name']]
            }
          elsif sub_answer['has_table']
            sub_answer['table_data'].each do |table_data|
              table_data.each do |table_row|
                @data << {
                  data: calculate_average_table_data(companies_data, table_row['name'], @current_user_answer, q_id)
                }
                answervalue = @current_user_answer[table_row['name']]
                if answervalue.present?
                  answervalue = answervalue
                else
                  answervalue = ''
                end
                @answers << {
                  ans: answervalue,
                  name: table_row['name'],
                  checkbox_name: @current_user_answer[q_id.downcase.underscore],
                  orignalans: @current_user_answer[table_row['name']]
                }
              end
            end
          end
        end
      end
    end
  
    @first_value = @value.first
  end  

  def fetch_analytics_graphs_data
    @get_question = find_question(params[:question])
    @chart_data = []
    @answers = []
     
    if params[:status] == 'cross'
      companies_data = @total_answers_data
    else
      if pb_questions.include?(params[:question])
        companies_data = @total_answers_data_sectorwise
      else
        companies_data = @total_answers_data_sectorwise
      end
    end

    case params[:question]
    when 'PB-01', 'PB-04', 'PB-09', 'PB-11', 'PB-14', 'PB-16', 'PB-17', 'PB-18', 'PB-21', 'PB-22', 'PB-23', 'PB-24', 'PB-25', 'PB-27', 'PB-28', 'PB-29', 'PB-30', 'PB-31', 'PB-32', 'PB-34'
      @table_rows = find_table_rows(@get_question)
      @table_rows.map do |sub|
        if sub['name'].present?
          @chart_data << calculate_average(companies_data, sub['name'], @current_user_answer, params[:question])
        end
      end
  
      if params[:question] == 'PB-11'
        @valueelven = []
        row_name_to_category = {
          'pb_11_table_row1_number1' => 'R_D',
          'pb_11_table_row2_number1' => 'capex'
        }
      
        @table_rows.each do |sub|
          category = row_name_to_category[sub['name']]
          next unless category
      
          @valueelven << {
            trend: calculate_trend(companies_data, sub['name'], @current_user_answer, params[:question], category),
            investing: calculate_investing(companies_data, sub['name'], @current_user_answer, params[:question], category),
            commitment: calculate_commitment(companies_data, sub['name'], @current_user_answer, params[:question], category)
          }
        end
      end
  
      @table_rows.each do |sub|
        if sub['name'].present?
        answervalue = @current_user_answer[sub['name']]
        @answers << {
          ans: answervalue.to_f.round,
          name: sub['name'],
          checkbox_name: @current_user_answer[params[:question].downcase.underscore],
          orignalans: @current_user_answer[sub['name']]
        }
        end
      end
  
      @get_question.options.each do |question_option|
        if question_option['sub_answers'].present?
          question_option['sub_answers'].each do |sub_answer|
            valid_questions = ['PB-24', 'PB-28', 'PB-29', 'PB-30', 'PB-31', 'PB-14']
            if valid_questions.include?(params[:question])
              @chart_data << {
                percentage: calculate_percentage_seventhquestion(companies_data, sub_answer, params[:question])
              }
              answervalue = @current_user_answer[sub_answer['name']]
              @answers << {
                ans: answervalue,
                name: sub_answer['name'],
                checkbox_name: @current_user_answer[params[:question].downcase.underscore],
                orignalans: @current_user_answer[sub_answer['name']]
              }
            end
          end
        end
      end
      if params[:question] == 'PB-32'
        valid_answers = ['pb_32_option11_checkbox1', 'pb_32_option12_checkbox1']
          valid_answers.each do |ans|
            @chart_data << {
                percentage: calculate_percentage_seventhquestion(companies_data, ans, params[:question])
            }
            answervalue = @current_user_answer[ans]
            @answers << {
              ans: answervalue,
              name: ans,
              checkbox_name: @current_user_answer[params[:question].downcase.underscore],
              orignalans: @current_user_answer[ans]
            }
          end
      end
    when 'PB-06'
      @valuesix = @get_question.options.each_with_object([]) do |question_option, valuesix|
        if question_option['sub_answers'].present?
          question_option['sub_answers'].each do |sub_answer|
            valuesix << {
              ethics: calculate_ethics(companies_data, sub_answer['name'], params[:question])
            }
            answervalue = @current_user_answer[sub_answer['name']]
            @answers << {
              ans: answervalue,
              name: sub_answer['name'],
              checkbox_name: @current_user_answer[params[:question].downcase.underscore],
              orignalans: @current_user_answer[sub_answer['name']]
            }
            if sub_answer['sub_answers']
              sub_answer['sub_answers'].each do |subanswer_2|
                if %w[pb_06_option1_radio pb_06_option2_radio].include?(subanswer_2['name']) && subanswer_2['label'] == 'Internal Policy'
                  valuesix << {
                    coc: calculate_coc(companies_data, subanswer_2['name'], params[:question]),
                    empcoc: calculate_empcoc(companies_data, subanswer_2['name'], params[:question])
                  }
                  answervalue = @current_user_answer[subanswer_2['name']]
                  @answers << {
                    ans: answervalue,
                    name: subanswer_2['name'],
                    checkbox_name: @current_user_answer[params[:question].downcase.underscore],
                    orignalans: @current_user_answer[subanswer_2['name']]
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
            if params[:question] == 'PB-19'
              value << {
                graphone: calculate_threeoptions_choosen_percentage(companies_data, sub_answer, params[:question]),
                graphtwo: calculate_percentage_seventhquestion(companies_data, sub_answer, params[:question])
              }
            elsif params[:question] == 'PB-02' || params[:question] == 'PB-03' || params[:question] == 'PB-12' || params[:question] == 'PB-33'
              value << {
                values: calculate_average(companies_data, sub_answer['name'], @current_user_answer, params[:question])
              }
            elsif %w[PB-07 PB-08 PB-10 PB-15 PB-26 PB-35].include?(params[:question])
              value << {
                percentage: calculate_percentage_seventhquestion(companies_data, sub_answer, params[:question])
              }
            else
              value << {
                percentage: calculate_percentage(companies_data, sub_answer, params[:question])
              }
            end
            answervalue = @current_user_answer[sub_answer['name']]
            @answers << {
              ans: answervalue,
              name: sub_answer['name'],
              checkbox_name: @current_user_answer[params[:question].downcase.underscore],
              orignalans: @current_user_answer[sub_answer['name']]
            }
          end
        end
      end
  
    when 'PB-13'
      @percentage_names = ['pb_13_percentage_1', 'pb_13_percentage_2']
      @valuethirteen = []
      @percentage_names.each do |names|
        answervalue = @current_user_answer[names]
        @answers << {
            ans: answervalue,
            name: names,
            checkbox_name: @current_user_answer[params[:question].downcase.underscore],
            orignalans: @current_user_answer[names]
        }
        @valuethirteen << {
            average: calculate_average(companies_data,names, @current_user_answer, params[:question])
        }
      end   
      @valuethirteen << {
          lca_average: calculate_lca_percentage(companies_data, @current_user_answer, params[:question])
      }
      @pb_13_names = ['pb_13_suboption_checkbox1', 'pb_13_suboption_checkbox2', 'pb_13', 'pb_13_option_checkbox2']
      @pb_13_names.each do |names|
        answervalue = @current_user_answer[names]
        @answers << {
          ans: answervalue,
          name: names,
          checkbox_name: @current_user_answer[params[:question].downcase.underscore],
          orignalans: @current_user_answer[names]
        }
      end
  
    when 'PB-20'
      @valuetwenty = find_values(@get_question, params[:question], companies_data)
    end
  
    render json: {
      company_data: @chart_data,
      percentage: @value,
      question: params[:question],
      valuesix: @valuesix,
      valuethirteen: @valuethirteen,
      valuetwenty: @valuetwenty,
      answers: @answers,
      valueelven: @valueelven,
      industry_status: params[:status]
    }
  end
  
  def analytics_calculation
    # The instance variables @questions, @current_user_answer, @total_answers_data_sectorwise, and @total_answers_data are already set by set_variables before_action
  end

  private

  def find_question(question)
    PeerBenchmarkingQuestionnaire.find_by(question_id: question)
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

  def find_values(question, q_id, companies_data)
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
                  numbers: calculate_average(companies_data, table_row['name'], @current_user_answer, q_id)
                }
                answervalue = @current_user_answer[table_row['name']]
                @answers << {
                  ans: answervalue.to_f.round,
                  name: table_row['name'],
                  checkbox_name: @current_user_answer[q_id.downcase.underscore],
                  orignalans: @current_user_answer[table_row['name']]
                }
              end
            end
          end
          sub_answer['sub_answers'].each do |sub| 
              if sub['name'] == 'pb_20_option11_checkbox1' || sub['name'] == 'pb_20_option21_checkbox1'
                @value << {
                  percentage: calculate_optiontwo_choosen_percentage(companies_data, sub['name'], q_id, 'Data has been assured/verified by third party')
                }
                answervalue = @current_user_answer[sub['name']]
                firstcheckbox = @current_user_answer['pb_20_option1_checkbox1']
                @answers << {
                  ans: answervalue,
                  name: sub['name'],
                  checkbox_name: @current_user_answer[q_id.downcase.underscore],
                  orignalans: @current_user_answer[sub['name']],
                  firstcheckbox: firstcheckbox
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

  def set_variables
    @questions = PeerBenchmarkingQuestionnaire.all.order(question_id: :asc)
    @user_answers = PeerBenchmarkingAnswer.find_by(user_id: current_user.id, version: current_year)
    if @user_answers
      @current_user_answer = @user_answers.user_answers
      if @user_answers.version != current_year
        @current_user_answer = interchange_table_data(@current_user_answer, [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
        @current_user_answer = interchange_table_data(@current_user_answer, [16, 17, 18, 22, 23], same_row: false )
      end
    else
      @current_user_answer = ''
    end
    # @total_answers_data_sectorwise = PeerBenchmarkingAnswer.where.not(user_id: current_user.id).where(sector: current_user.company_sector, version: current_year)
    # @total_answers_data = PeerBenchmarkingAnswer.where.not(user_id: current_user.id, version: current_year)

    @datacollection = DataCollectionCompanyDetail.find_by(create_user_id: current_user.id)
    if @datacollection
      condition_check = true
      condition_check_2 = true
      @total_answers_data_sectorwise = DataCollectionCompanyDetail
                                      .where.not(id: @datacollection[:id])
                                      .where(status: ApplicationRecord::WORK_SUBMITTED)
                                      .where(company_sector: current_user.company_sector)
                                      .joins("INNER JOIN data_collection_answers ON data_collection_company_details.id = data_collection_answers.company_id")
                                      # .where(data_collection_answers: { version: current_year })
                                      .where(data_collection_answers: { version: DataCollectionAnswer
                                      .select('MAX(version)')
                                      .group(:company_id)
                                      .where('data_collection_answers.company_id = data_collection_company_details.id') })
                                      .select("data_collection_answers.*")
      user_answers = @total_answers_data_sectorwise.map do |company_detail|
        {
            answers: company_detail.user_answers,
            version: company_detail.version 
        }
      end
      user_answers.each do |data|
        if data[:version] != current_year
          updated_data = interchange_table_data(data[:answers], [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
          updated_data = interchange_table_data(data[:answers], [16, 17, 18, 22, 23], same_row: false )
          data[:answers] = updated_data
        else 
          condition_check = false
          break
        end
      end
      if condition_check
        @total_answers_data_sectorwise.each_with_index do |company_detail, index|
          company_detail.user_answers = user_answers[index][:answers]
        end    
      end
      @total_answers_data =  DataCollectionCompanyDetail
                            .where.not(id: @datacollection[:id])
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
            company_sector: company_detail.company_sector,
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
          # data.replace(updated_data)
          data[:answers] = updated_data
          @data = DataCollectionAnswer.find_by(company_id: data[:company_id], version: current_year)
          if @data.nil?
            DataCollectionAnswer.create(status: data[:status], company_id: data[:company_id], sector: data[:company_sector], user_answers: updated_data, submitted_at: data[:submitted_at], version:  current_year, company_name: data[:company_name], hidden_company_name: data[:hidden_company_name])
          end
        else
          condition_check_2 = false
          break
        end
      end
      if condition_check_2
        @total_answers_data.each_with_index do |company_detail, index|
            # company_detail.user_answers = user_answers[index] # assuming user_answers is the field
            company_detail.user_answers = user_answers[index][:answers]
        end    
      end
    else
      condition_check = true
      condition_check_2 = true
      @total_answers_data_sectorwise = DataCollectionCompanyDetail
                                      .where(status: ApplicationRecord::WORK_SUBMITTED)
                                      .where(company_sector: current_user.company_sector)
                                      .joins("INNER JOIN data_collection_answers ON data_collection_company_details.id = data_collection_answers.company_id")
                                      # .where(data_collection_answers: { version: current_year })
                                      .where(data_collection_answers: { version: DataCollectionAnswer
                                      .select('MAX(version)')
                                      .group(:company_id)
                                      .where('data_collection_answers.company_id = data_collection_company_details.id') })
                                      .select("data_collection_answers.*")
      user_answers = @total_answers_data_sectorwise.map do |company_detail|
        {
            answers: company_detail.user_answers,
            version: company_detail.version 
        }
      end
      user_answers.each do |data|
        if data[:version] != current_year
          updated_data = interchange_table_data(data[:answers], [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
          updated_data = interchange_table_data(data[:answers], [16, 17, 18, 22, 23], same_row: false )
          data[:answers] = updated_data
        else 
          condition_check = false
          break
        end
      end
      if condition_check
        @total_answers_data_sectorwise.each_with_index do |company_detail, index|
          company_detail.user_answers = user_answers[index][:answers]
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
        else 
          condition_check_2 = false
          break
        end
      end
      if condition_check_2
        @total_answers_data.each_with_index do |company_detail, index|
          company_detail.user_answers = user_answers[index][:answers]
        end   
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
