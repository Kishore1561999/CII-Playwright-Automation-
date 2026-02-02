class CompanyUser::PublicationController < ApplicationController
    before_action :authenticate_user!
    before_action :subscription_check

    def publications
        @company_name = params[:companyName].present? ? params[:companyName] : ""
        @company_users = CiiPublication.order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
        @company_users = @company_users.order(created_at: :desc).where(params[:sector_ids].present? ? { company_sector: sector_names } : {})
        @company_users = @company_users.search_by(params[:companyName]) if params[:companyName].present?
        @company_users = @company_users.by_creation_date(params[:year]) if params[:year].present?
        @company_users = @company_users.paginate(page: params[:page], per_page: 10)
    end

    private

    def subscription_check
        current_dashboard = current_user.subscription_esg_diagnostic? && current_user.approved? ? company_user_dashboard_path : peer_benchmarking_path
        unless current_user.subscription_approved == "premium"
            redirect_to current_dashboard, alert: "You need to subscribe to access this page."
        end
    end
end