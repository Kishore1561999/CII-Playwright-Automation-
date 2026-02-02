class Service::BasicSubscriptionController < ApplicationController
    include FilterHelper
    before_action :set_company_user, only: [:edit]
    before_action :authenticate_user!
    before_action :user_role_check
    
    def index
      @sector_ids = params[:sector_ids] || []
      @company_users = filter_company_users("Basics", params, "")
    end

    def update_status
      update_company_user_status(params[:id], params[:status], basic_subscription_path)
    end

    def export_excel
      @users = User.company_users.where(subscription_services: "Basics")
      export_excel_data(@users, 'service/premium_subscription/export_excel')
    end

    def destroy
      @company_user = User.find(params[:id])
      @company_user.update(basic_delete_status: ApplicationRecord::DELETE_STATUS, deleted_at: Time.now)
      #@company_user.destroy
  
      respond_to do |format|
        format.html { redirect_to basic_subscription_path, notice: 'Company User has been deleted successfully.' }
      end
    end

    def edit
      render template: "service/premium_subscription/edit"
    end

    private
    
    def set_company_user
      @company_user = User.find(params[:id])
    end
end
