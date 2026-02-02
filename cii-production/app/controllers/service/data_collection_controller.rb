class Service::DataCollectionController < ApplicationController
    before_action :authenticate_user!
    include FilterHelper
    include ApplicationHelper
    before_action :user_role_check

    def index
      @page = params[:page].present? ? params[:page].to_i : 1
      @tab = params[:tab].present? ? params[:tab].to_i : 0
      @company_detail = DataCollectionCompanyDetail.where('analyst_user_id = ? OR ? = 0', current_user.id, (params[:my_companies].present? || @tab == 1) ? 1 : 0).order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
      service_filter_helper(@company_detail, params)
      @company_detail = @company_detail.paginate(:page => params[:page] || 1, :per_page => 10)
      respond_to do |format|
        format.html
        format.js { render partial: 'service/data_collection/data_collection_user_table' }
      end
    end

    def data_collection_assessment
      @questions = DataCollectionQuestionnaire.for_version(current_year)
      @company = find_company(params[:company_id])
      @company.update(status: ApplicationRecord::WORK_IN_PROGRESS)
      @answer = find_data_collection_answer(params[:company_id], current_year)
      @answer_present = @answer.present?
      @user_answers = Answers::AnswerService.datacollection_answer_merger(@answer)
      if @answer.present?
      if @answer.version != current_year
        @user_answers = interchange_table_data(@user_answers, [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
        @user_answers = interchange_table_data(@user_answers, [16, 17, 18, 22, 23], same_row: false )
      end
      end
    end

    def submit_providedata
      company = find_company(params[:company_id])
      company.update(status: ApplicationRecord::WORK_SUBMITTED)
      redirect_to data_collection_dashboard_path(subscription_type: params[:subscription_type]), notice: "Response has been submitted successfully!"
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

    def view_providedata
      @questions = DataCollectionQuestionnaire.for_version(current_year)
      @company = find_company(params[:company_id])
      @answer = find_data_collection_answer(params[:company_id], current_year)
      @user_answers = Answers::AnswerService.datacollection_answer_merger(@answer)
      if @answer.present?
      if @answer.version != current_year
        @user_answers = interchange_table_data(@user_answers, [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
        @user_answers = interchange_table_data(@user_answers, [16, 17, 18, 22, 23], same_row: false )
      end
      end
    end

    def fetch_companydata
      @company = find_company(params[:company_id])
      @filename = @company.pdffile.filename.to_s if @company.pdffile.attached?
      render json: { company_data: @company, filename: @filename }
    end

    def pushback
      company = find_company(params[:company_id])
      company.update(status: ApplicationRecord::PUSH_BACK)
      begin
        UserMailer.company_pushed_back(company).deliver_later
       rescue StandardError => e
         Rails.logger.error "Failed to send email: #{e.message}"
       end
      
      redirect_to data_collection_dashboard_path(subscription_type: params[:subscription_type]), notice: "Data has been pushbacked successfully!"
    end

    def clear
      answer = DataCollectionAnswer.find_by(company_id: params[:company_id])
      answer.destroy
      redirect_to data_collection_assessment_path(subscription_type: params[:subscription_type]), notice: "Data has been cleared successfully!"
    end

    def save_data_collection_assessment
      save_answer
    end

    def fetch_data_collection_data
      @answer = find_data_collection_answer(params[:company_id], current_year)
      @user_answers = @answer.present? ? @answer.user_answers : {}
      if @answer.present?
        if @answer.version != current_year
          @user_answers = interchange_table_data(@user_answers, [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
          @user_answers = interchange_table_data(@user_answers, [16, 17, 18, 22, 23], same_row: false )
        end
      end
      render json: { aspect_data: @user_answers }
    end

    def destroy
      @company = find_company(params[:company_id])
      @company.destroy
      answer = DataCollectionAnswer.find_by(company_id: params[:company_id])
      if answer.present? 
        answer.destroy
      end
      redirect_to data_collection_dashboard_path(subscription_type: params[:subscription_type]), notice: 'Company was successfully deleted.'
    end

    def data_automation
      @company_detail = find_company(params[:company_id])
      if params[:xmlfile].present? 
        @company_detail.xmlfile.attach(params[:xmlfile])
        @company_detail.update(update_user_id: current_user.id, upload_status: 'Prefill')
          xml_path = ActiveStorage::Blob.service.path_for(@company_detail.xmlfile.key)
          open_xml_file = File.open(xml_path)
          xml_data = Nokogiri::XML(open_xml_file)
          # Extract the namespace dynamically
          namespace = xml_data.namespaces["xmlns:in-capmkt"]
          collection_answer = DataCollectionAnswer.find_or_create_by(company_id: params[:company_id], sector: @company_detail.company_sector, version: current_year)
          xml_data_question_elements = DataCollectionXmlDataQuestion.pluck(:element, :cii_question_name).to_h
          xml_data_questions = DataCollectionXmlDataQuestion.pluck(:xml_question_name, :cii_question_name).to_h
          answers = {}
          @ans = []
          xml_data_question_elements.keys.each do |xml_data_question_element|
            data = xml_data.xpath("//in-capmkt:*", 'in-capmkt' => namespace)
      
            data.each do |d|
              context_ref = d['contextRef']
              next unless d.name == xml_data_question_element && xml_data_questions.keys.include?(context_ref)
      
              xml_question = DataCollectionXmlDataQuestion.find_by(element: d.name, xml_question_name: context_ref)
              next unless xml_question
      
              cii_question_name = xml_question.cii_question_name
              is_percentage = xml_question.is_percentage
              answers[cii_question_name[0..4]] = 'information_available'
              striped_text = d.text.strip
              if cii_question_name == 'pb_19_textarea'
                @ans << striped_text
              end
              question_checkbox_map = {
                'pb_28_textarea' => 'pb_28_option_checkbox',
                'pb_29_textarea' => 'pb_29_option_checkbox',
                'pb_30_textarea' => 'pb_30_option_checkbox',
                'pb_31_textarea' => 'pb_31_option_checkbox'
              }

              if question_checkbox_map.key?(cii_question_name) && striped_text.downcase == 'true'
                answers[question_checkbox_map[cii_question_name]] = 'Independent assessment/ evaluation/assurance has been carried out by an external agency'
              end
              answers[cii_question_name] = is_percentage ? (striped_text.to_f * 100).round(5).to_s : striped_text
              if cii_question_name == 'pb_05_option_checkbox1'
                if striped_text.downcase == 'yes'
                  answers['pb_05_option_checkbox1'] = 'Employees'
                  answers['pb_05_option_checkbox2'] = 'Workers'
                end
              end
              if cii_question_name == 'pb_05_option_checkbox3'
                #binding.pry
                if striped_text.downcase == 'yes'
                  answers['pb_05_option_checkbox3'] = 'Communities'
                end
                #binding.pry
              end
              if cii_question_name == 'pb_05_option_checkbox4'
                if striped_text.downcase == 'yes'
                  answers['pb_05_option_checkbox4'] = 'Value chain partners'
                end
              end
              if cii_question_name == 'pb_05_option_checkbox5'
                if striped_text.downcase == 'yes'
                  answers['pb_05_option_checkbox5'] = 'Customers'
                end
              end
            end
          end
          answers['pb_19_textarea'] = @ans.join("\n\n") # Combine all answers into a single string
          collection_answer.update(user_answers: answers)
          notice_msg = 'File has been upload and prefilled successfully.'
          #File.read(ActiveStorage::Blob.service.path_for(@company_detail.xmlfile.key))
        
      end
  
      redirect_to data_collection_assessment_path(subscription_type: params[:subscription_type]), notice: notice_msg
    end

    def data_collection_company
      @tab = params[:page_tab]
      @page = params[:page_num]
      if params[:company_id].present? 
        company = find_company(params[:company_id])
        update_params = {
          company_name: params[:company_name] ? params[:company_name]&.squish : company.company_name,
          company_isin_number: params[:company_isin_number],
          company_sector: params[:company_sector] ? params[:company_sector] : company.company_sector,
          analyst_user_id: params[:analyst_user_id],
          subscription_services: params[:subscription_services],
          user_type: ApplicationRecord::CII_USER,
          selected_year: params[:selected_year],
          company_update_user_id: current_user.id
          }.compact
        company.update(update_params)
        if params[:pdffile].present? 
          company.pdffile.attach(params[:pdffile])
        end
        msg = 'Company has been updated successfully.'
      else
        @data_collection_company = DataCollectionCompanyDetail.create(
          company_name: params[:company_name]&.squish,
          company_isin_number: params[:company_isin_number],
          company_sector: params[:company_sector],
          analyst_user_id: params[:analyst_user_id],
          subscription_services: params[:subscription_services],
          user_type: ApplicationRecord::CII_USER,
          selected_year: params[:selected_year],
          create_user_id: current_user.id
        )
        if params[:pdffile].present? 
          @data_collection_company.pdffile.attach(params[:pdffile])
        end  
        msg = 'Company has been created successfully.'
      end
      redirect_to data_collection_dashboard_path(page: @page, tab: @tab, subscription_type: params[:subscription_services]), notice: msg
    end

    def assign_analyst
      @analyst_user = User.find(params[:id])
      company_id = params['company_id'].split(",")
  
      company_id.each do |companyid|
        assigned_data = find_company(companyid)
        assigned_data.update(analyst_user_id: params[:id], status: ApplicationRecord::WORK_IN_PROGRESS)
        begin
          UserMailer.company_assigned_data_collection(@analyst_user, assigned_data).deliver_later
         rescue StandardError => e
           Rails.logger.error "Failed to send email: #{e.message}"
         end
        
      end
      redirect_to data_collection_dashboard_path(subscription_type: params[:subscription_type]), notice: 'Analyst has been successfully assigned.'
    end

    def company_exists
      result = check_company_existence(params[:company_name], params[:company_sector], params[:buttonText], params[:company_id])
      render json: result
    end

    private

    def save_answer
      Rails.logger.info "Admin Added CII Data Collection Answer_to #{params[:company_id]}"
      answer_exist = DataCollectionAnswer.find_by(company_id: params[:company_id], version: current_year) 
      company_hidden_name = params[:company_hidden_name].strip.squeeze(' ')                           # hidden field compny name
      company = find_company(params[:company_id])
      company_name = company.company_name.strip.squeeze(' ') 
      if company_hidden_name != company_name || params[:company_id].to_s != params[:company_hidden_id].to_s
        # can we check the answer_exist is present or not and hidden_id_answer_exists present or not
        Rollbar.error('Company mismatch happened', {params_company_name: company_name, params_company_id: params[:company_id].to_s, company_hidden_id: params[:company_hidden_id].to_s, company_hidden_name: company_hidden_name})
        hidden_id_answer_exist = DataCollectionAnswer.find_by(company_id: params[:company_id], version: current_year)
        DataCollectionErrorLog.create(user_id: current_user.id, company_id: params[:company_id], hidden_company_id: params[:company_hidden_id], company_name: company_name, hidden_company_name: company_hidden_name, hidden_id_user_answers: hidden_id_answer_exist.user_answers, params_id_user_answers: answer_exist.user_answers, current_answer: JSON.parse(params['user_answers']))
        company = find_company(params[:company_hidden_id])
        answer_exist = hidden_id_answer_exist
        params[:company_id]  = params[:company_hidden_id]
      end
      company.update(update_user_id: current_user.id)
      if company.status != ApplicationRecord::WORK_SUBMITTED
        if answer_exist.present?
          if answer_exist.company_id.to_s == params[:company_hidden_id].to_s
              answer_exist.update(user_answers: JSON.parse(params['user_answers']), submitted_at: DateTime.now, company_name: company.company_name, hidden_company_name: params[:company_hidden_name])
          else
            Rollbar.error('User Answer exists but mismatch happened', {params_company_name: company_name, params_company_id: params[:company_id].to_s, company_hidden_id: params[:company_hidden_id].to_s, company_hidden_name: company_hidden_name})
          end
        else
          DataCollectionAnswer.create(company_id: params[:company_id], sector: company.company_sector, user_answers: JSON.parse(params['user_answers']), submitted_at: DateTime.now, version:  current_year, company_name: company.company_name, hidden_company_name: params[:company_hidden_name])
        end
      end
    rescue Exception => e
      Rollbar.error('Data Collection has been Save', e)
    end

    def find_data_collection_answer(company_id, version)
      
      @data = DataCollectionAnswer.find_by(company_id: company_id, version: version)
      if @data.present?
        DataCollectionAnswer.find_by(company_id: company_id, version: version)
      else
        DataCollectionAnswer.where(company_id: company_id).order(version: :desc).first
      end
    end

    def find_company(company_id)
      DataCollectionCompanyDetail.find_by(id: company_id)
    end
end
  