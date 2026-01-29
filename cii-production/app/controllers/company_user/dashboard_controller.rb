class CompanyUser::DashboardController < ApplicationController
  include FilterHelper
  before_action :authenticate_user!
  before_action :subscription_restrict
  before_action :deleted_user_restrict
  def index
    @has_score = CompanyScore.where(company_user_id: current_user.id).count
    @report = Report.find_by(company_user_id: current_user.id)
  end

  def send_inquiry_email
    begin
      UserMailer.send_inquiry_email_to_cii(current_user).deliver_later
     rescue StandardError => e
       Rails.logger.error "Failed to send email: #{e.message}"
     end
    
    redirect_to peer_benchmarking_path, notice: 'Your enquiry has been sent to CII team. They will reach out at the earliest.'
  end

  private

    def subscription_restrict
      if !current_user.approved?
        redirect_to peer_benchmarking_path, alert: "You need to subscribe to access this page."
      end
    end
end
