class CompanyUser::EsgLearningController < ApplicationController
    before_action :authenticate_user!
    include FilterHelper
    before_action :subscription_check

    def esg_learnings
        @tab = params[:tab].present? ? params[:tab].to_i : 0
        @company_name = params[:companyName].present? ? params[:companyName] : ""
        if @tab == 0
        @company_users = CiiElearning.order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
        @company_users = @company_users.search_by(params[:companyName]) if params[:companyName].present?
        @company_users = @company_users.by_creation_date(params[:year]) if params[:year].present? 
        else
        learning_ids = EsgLearning.where(status: "approved", company_user_id: current_user.id).pluck(:learning_id)
        @company_users = CiiElearning.where(id: learning_ids)
        @company_users = @company_users.search_by(params[:companyName]) if params[:companyName].present?
        @company_users = @company_users.by_creation_date(params[:year]) if params[:year].present? 
        end
        respond_to do |format|
            format.html
            format.js { render partial: 'company_user/esg_learning/company_user_elearning_user_table' }
        end
    end

    def approval
        @learning_id = params[:elearning_id].to_i
        @elearning_creation = EsgLearning.create(
            learning_id: @learning_id,
            company_user_id: current_user.id,
            status: "pending"
            )
        msg = 'Your Request has been sent to the team. They will reach out at the earliest.'
        begin
            UserMailer.elearning_download_request(@learning_id, current_user).deliver_later
        rescue StandardError => e
            Rails.logger.error "Failed to send email: #{e.message}"
        end
       
        redirect_to esg_learnings_path, notice: msg
    end

    private

    def subscription_check
        current_dashboard = current_user.subscription_esg_diagnostic? && current_user.approved? ? company_user_dashboard_path : peer_benchmarking_path
        unless current_user.subscription_approved == "premium"
            redirect_to current_dashboard, alert: "You need to subscribe to access this page."
        end
    end
end