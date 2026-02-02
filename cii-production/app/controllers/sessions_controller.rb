class SessionsController < Devise::SessionsController
  def create
		super do |resource|
			validity = resource.subscription_approved_at.present? ? resource.subscription_approved_at > 1.year.ago : true
			if resource.approved_or_subscribed? && (resource.diagonsitics_delete_status.nil? || (resource.basic_delete_status.nil? && resource.premium_delete_status.nil?) )
				flash[:notice] = validity ? "Signed in successfully." : "Your subscription plan is expired please renew your subscription."
				redirect_to current_user_dashboard
				return
			else
				sign_out
				flash[:notice] = resource.diagonsitics_delete_status.nil? || resource.basic_delete_status.nil? ? "Your account is yet to be activated." : "Your account has been deactivated."
				redirect_to new_user_session_path
				return
			end
		end
	end

	def destroy
		cookies.delete(:modal_opened)
		super do |resource|
			flash[:notice] = params[:session_time_out].present? ? "Session Timeout, Please log in again..." : "Logged out successfully."
			redirect_to new_user_session_path
			return
		end
	end

  def current_user_dashboard
    if current_user.is_admin?
      admin_company_users_path
    elsif current_user.is_analyst?
      analyst_dashboard_path
    elsif current_user.is_company_user?
		if current_user.subscription_esg_diagnostic? && current_user.approved? && current_user.diagonsitics_delete_status.nil?
			company_user_dashboard_path
		else
			peer_benchmarking_path
		end
    elsif current_user.is_manager?
      manager_company_users_path
    end
  end
end
