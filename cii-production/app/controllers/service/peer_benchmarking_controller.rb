class Service::PeerBenchmarkingController < ApplicationController
    include FilterHelper
    before_action :authenticate_user!
    before_action :user_role_check
    include ApplicationHelper

    def index
        @sector_ids = params[:sector_ids] || []
        @company_users = filter_company_users("", params, "", include_consent_form: true)
        @company_existence_details = {}
    
        @company_users.each do |company_user|
          user = User.company_users.find(company_user.id)
          @company_existence_details[company_user.id] = {
            existing_company_details: DataCollectionCompanyDetail.where(create_user_id: company_user.id, company_sector: user.company_sector),
            company_existence: peer_benchmark_check_company_existence(company_user.company_name, user.company_sector)
          }
        end
    end

    def update_status
        company_user = set_peer_benchmark_answer(params[:id])
        update_params = {
            admin_analytics_status: params[:status] == 'rejected' ? params[:status] : "approved",
        }
        if company_user.update(update_params)
            if params[:status] == 'approved'
                data_collection_analytics_company(params[:id])
            end
            redirect_to cii_peer_benchmarking_path, notice: 'Status Updated Successfully'
        else
        redirect_to cii_peer_benchmarking_path, error: 'Company User request status update has been failed.'
        end    
    end

    def update_duplicate_company
        company_user = set_peer_benchmark_answer(params[:user_id])
        company_user.update(admin_analytics_status: "approved")
        if params[:status] == "create"
            data_collection_analytics_company(params[:user_id])
        else
            update_duplicate_check_company(params[:user_id])
        end
         redirect_to cii_peer_benchmarking_path, notice: 'Status Updated Successfully'
    end

    private

    def data_collection_analytics_company(user_id)
      ActiveRecord::Base.transaction do
        company_user = set_company_user(user_id)
        @data_collection_company = DataCollectionCompanyDetail.create(
            company_name: company_user.company_name,
            company_isin_number: company_user.company_isin_number,
            company_sector: company_user.company_sector,
            create_user_id: user_id,
            user_type: ApplicationRecord::COMPANY_USER
        )
        peer_benchmark = set_peer_benchmark_answer(user_id)
        @data_collection_answer = DataCollectionAnswer.create(
            company_id: @data_collection_company.id,
            sector: @data_collection_company.company_sector,
            status: @data_collection_company.status,
            user_answers: peer_benchmark.user_answers,
            version: peer_benchmark.version
        )
      end
    rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Creation failed: #{e.message}")
        raise
    end

    def update_duplicate_check_company(user_id)
       company_user = set_company_user(user_id)
       duplication_check = peer_benchmark_check_company_existence(company_user.company_name, company_user.company_sector)
       data_collection =  DataCollectionCompanyDetail.find(duplication_check[:id])
       data_collection.update(updated_at: Time.now, status: ApplicationRecord::WORK_IN_PROGRESS)
       data_collection_answer = DataCollectionAnswer.find_by(company_id: duplication_check[:id])
       peer_benchmark = set_peer_benchmark_answer(user_id)
       if data_collection_answer.present? 
            @update_data_collection_company = data_collection_answer.update(
                user_answers: peer_benchmark.user_answers,
                version: peer_benchmark.version
            )
        else
            @data_collection_answer = DataCollectionAnswer.create(
                company_id: duplication_check[:id],
                sector: data_collection.company_sector,
                status: data_collection.status,
                user_answers: peer_benchmark.user_answers,
                version: peer_benchmark.version
            )
       end
       
        # company_user = set_company_user(user_id)
        # data_collection =  DataCollectionCompanyDetail.find_by(create_user_id: user_id, company_sector: company_user.company_sector)
        # data_collection.update(updated_at: Time.now)
        # data_collection_answer = DataCollectionAnswer.find_by(company_id: data_collection.id)
        # peer_benchmark = set_peer_benchmark_answer(user_id)
        # @update_data_collection_company = data_collection_answer.update(
        #     user_answers: peer_benchmark.user_answers,
        #     version: peer_benchmark.version
        # )
    end

    def set_peer_benchmark_answer(user_id)
        @data = PeerBenchmarkingAnswer.find_by(user_id: user_id, version: Time.now.year)
        if @data.present?
            PeerBenchmarkingAnswer.find_by(user_id: user_id, version: Time.now.year)
        else
            PeerBenchmarkingAnswer.where(user_id: user_id).order(version: :desc).first
        end
    end

    def set_company_user(user_id)
        User.company_users.find(user_id)
    end
  
end