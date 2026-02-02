class Service::PremiumSubscriptionController < ApplicationController
    include FilterHelper
    before_action :set_company_user, only: [:edit, :update, :destroy]
    before_action :authenticate_user!
    before_action :user_role_check

    def index
      @sector_ids = params[:sector_ids] || []
      @company_users = filter_company_users("Premium", params, 'upgrading')
    end

    def update_status
      update_company_user_status(params[:id], params[:status], premium_subscription_path)
    end

    def export_excel
      @users = User.company_users.where(subscription_services: "Premium")
      export_excel_data(@users, 'service/premium_subscription/export_excel')
    end

    def destroy
      @company_user.update(premium_delete_status: ApplicationRecord::DELETE_STATUS, deleted_at: Time.now)
      #@company_user.destroy
  
      respond_to do |format|
        format.html { redirect_to premium_subscription_path, notice: 'Company User has been deleted successfully.' }
      end
    end

    def edit
    end          

    def update
      respond_to do |format|
        if @company_user.update(company_isin_number: params[:company_isin_number], company_name: params[:company_name], company_sector: params[:company_sector])
          PeerBenchmarkingAnswer.find_by(user_id: params[:id], version: Time.now.year)&.update(sector: params[:company_sector])
          data_collection_details = DataCollectionCompanyDetail.where(create_user_id:  params[:id])
          if data_collection_details.any?
            detail_to_update = data_collection_details.one? ? data_collection_details.first : data_collection_details.last
            detail_to_update.update(company_isin_number: params[:company_isin_number], company_name: params[:company_name], company_sector: params[:company_sector])
          end
          format.html { redirect_to determine_redirection_path, notice: 'Company User has been updated successfully.' }
        else
          format.html { render :edit }
        end
      end
    end

  private

  def set_company_user
    @company_user = User.find(params[:id])
  end

  def determine_redirection_path
    if params[:from] == 'basics'
      basic_subscription_path
    else
      premium_subscription_path
    end
  end
end
  