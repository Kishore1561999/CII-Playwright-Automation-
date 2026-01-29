class CompanyUser::PeerBenchmarkController < ApplicationController
    before_action :authenticate_user!
    before_action :set_answer
    before_action :subscription_check
    before_action :deleted_user_restrict_basic
    include ApplicationHelper

    def peer_benchmarking
    end

    def set_cookie
      cookies[:modal_opened] = true
    end
    
    def peer_benchmark_assessment
      @questions = PeerBenchmarkingQuestionnaire.where(version: current_year).order(id: :asc)
      @user_answers = Answers::AnswerService.peerbenchmark_answer_merger(@answer)
      @answer_present = @answer.present?
      if @answer.present?
        if @answer.version != current_year
          @user_answers = interchange_table_data(@user_answers, [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
          @user_answers = interchange_table_data(@user_answers, [16, 17, 18, 22, 23], same_row: false )
        end
      end
    end
  
    def save_peerbenchmark_assessment
      save_answer
    end
    
    def fetch_peerbenchmark_data
      @user_answers = @answer.present? ? @answer.user_answers : {}
      if @answer.present?
        if @answer.version != current_year
          @user_answers = interchange_table_data(@user_answers, [4, 11, 14, 20, 24, 26, 28, 29, 30, 31, 32])
          @user_answers = interchange_table_data(@user_answers, [16, 17, 18, 22, 23], same_row: false )
        end
      end
      render json: { aspect_data: @user_answers }
    end

    def peer_benchmark_answer_exist
      peerbenching_answer = PeerBenchmarkingAnswer.find_by(user_id: current_user.id)
      render json: { status: peerbenching_answer.present?  }
    end

    def delete_peer_benchmark_answer
      PeerBenchmarkingAnswer.find_by(user_id: current_user.id)&.destroy
      User.find_by(id: current_user.id)&.update(company_sector: params[:sector])

      data_collection_details = DataCollectionCompanyDetail.where(create_user_id: current_user.id)
      if data_collection_details.any?
        detail_to_update = data_collection_details.one? ? data_collection_details.first : data_collection_details.last
        detail_to_update.update(company_sector: params[:sector])
      end
      
      head :no_content
    end

    def update_peer_benchmark_answer
      PeerBenchmarkingAnswer.find_by(user_id: current_user.id, version: Time.now.year)&.update(sector: params[:sector])
      User.find_by(id: current_user.id)&.update(company_sector: params[:sector])
    
      data_collection_details = DataCollectionCompanyDetail.where(create_user_id: current_user.id)

      if data_collection_details.any?
        detail_to_update = data_collection_details.one? ? data_collection_details.first : data_collection_details.last
        detail_to_update.update(company_sector: params[:sector])
      end
    
      head :no_content
    end

    def upload_pdf
      if @answer.present?
        @answer.pdfreportfile.attach(params[:pdfreportfile])
        admin_emails = User.where(role_id: 1).pluck(:email)
        if @answer.update(status: "downloaded", admin_analytics_status: nil, updated_at: Time.now)
          redirect_to peer_benchmarking_path, notice: 'Report generated successfully and report has been sent to your mail'
          begin
            UserMailer.send_analytics_report_to_user(current_user, @answer.pdfreportfile.blob.signed_id, @answer.pdfreportfile.filename.to_s, admin_emails).deliver_later
          rescue StandardError => e
              Rails.logger.error "Failed to send email: #{e.message}"
          end
          
        else
          render json: { message: 'Failed to save PDF' }, status: :unprocessable_entity
        end
      else
        render json: { message: 'PeerBenchmarkingAnswer not found' }, status: :not_found
      end
    end

    def update_consent
      company_user = User.find(current_user.id)
      if company_user.update(consent_form: params[:user][:consent_form])
        render json: { message: 'Consent updated successfully' }, status: :ok
      else
        render json: { error: 'Failed to update consent' }, status: :unprocessable_entity
      end
    end

    def update_user_sector
      user_params = params.permit(:sector, :consent_form)
      current_user.update(company_sector: user_params[:sector], consent_form: user_params[:consent_form])
      redirect_to peer_benchmark_assessment_path
    end

    private

    def save_answer
      Rails.logger.info "Company user Added PeerBenchmarking Answered_to #{current_user.id}"
      @answer = PeerBenchmarkingAnswer.find_by(user_id: current_user.id, version: Time.now.year)
      answer_exist = @answer

      if answer_exist.present?
        answer_exist.update(user_answers: JSON.parse(params['user_answers']), submitted_at: DateTime.now)
      else
        PeerBenchmarkingAnswer.create(user_id: current_user.id, sector: current_user.company_sector, user_answers: JSON.parse(params['user_answers']), submitted_at: DateTime.now, version:  current_year)
      end
    rescue Exception => e
      Rollbar.error('Company User Assessment Save', e)
    end

    def set_answer
      @data = PeerBenchmarkingAnswer.find_by(user_id: current_user.id, version: Time.now.year)
      if @data.present?
        @answer = PeerBenchmarkingAnswer.find_by(user_id: current_user.id, version: Time.now.year)
      else
        @answer = PeerBenchmarkingAnswer.where(user_id: current_user.id).order(version: :desc).first
      end
    end

    def subscription_check
      if !current_user.subscription_approved.in?(["premium", "basics"])
        redirect_to company_user_dashboard_path, alert: "You need to subscribe to access this page."
      end
    end

    def deleted_user_restrict_basic
      if current_user.approved? && current_user.diagonsitics_delete_status.nil? && (!current_user.basic_delete_status.nil? || !current_user.premium_delete_status.nil?)
        redirect_to company_user_dashboard_path, alert: "Your Peerbenchmarking account has been deleted"
      elsif !current_user.diagonsitics_delete_status.nil? && (!current_user.basic_delete_status.nil? || !current_user.premium_delete_status.nil?)
        sign_out
				flash[:notice] =  "Your account has been deactivated."
				redirect_to new_user_session_path
				return
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