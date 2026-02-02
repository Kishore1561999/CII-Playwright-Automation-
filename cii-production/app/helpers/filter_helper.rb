module FilterHelper
  def filter_company_users(subscription_services, params, upgrade, include_consent_form: false)
    @company_name = params[:companyName].present? ? params[:companyName] : ""
    @search_year = params[:year].present? ? params[:year] : ""
    @sector_ids = params[:sector_ids] || []
    decoded_sector_names = CGI.unescape(params[:sector_ids] || "")
    sector_names = decoded_sector_names.split(",").map(&:strip).map { |sector_name| Sector.find_by(sector_name: sector_name)&.sector_name }
    if subscription_services == 'Premium'
      company_users = User.company_users.where(subscription_services: subscription_services).where(premium_delete_status: nil).order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
    elsif subscription_services == 'Basics'
      company_users = User.company_users.where(subscription_services: subscription_services).where(basic_delete_status: nil).order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
    end
    company_users = company_users.or(User.company_users.where(service_upgrade: upgrade)).order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC")) if upgrade.present?
    if include_consent_form 
      peerbenchmark = PeerBenchmarkingAnswer.where(status: "downloaded", version: Time.now.year).order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
      if peerbenchmark.present?
        peerbenchmark = PeerBenchmarkingAnswer.where(status: "downloaded", version: Time.now.year).order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
      else
        peerbenchmark = PeerBenchmarkingAnswer.where(status: "downloaded")
                                        .order(Arel.sql("CASE WHEN updated_at IS NULL THEN created_at ELSE updated_at END DESC"))
      end
      company_users_id = peerbenchmark.pluck(:user_id)
      order_clause = company_users_id.each_with_index.map do |id, index|
        "WHEN id = #{id} THEN #{index}"
      end.join(" ")
      company_users = User
        .where(consent_form: true, id: company_users_id)
        .where('basic_delete_status IS NULL AND premium_delete_status IS NULL')
        .reorder(Arel.sql("CASE #{order_clause} END"))
        company_users = company_users.order(created_at: :desc).where(params[:sector_ids].present? ? { company_sector: sector_names } : {})
    end
    company_users = company_users.order(created_at: :desc).where(params[:sector_ids].present? ? { company_sector: sector_names } : {}) if !include_consent_form
    company_users = company_users.search_by(params[:companyName]) if params[:companyName].present?
    company_users = company_users.by_creation_year(params[:year]) if params[:year].present?
    company_users.paginate(page: params[:page], per_page: 10)
  end

  def update_company_user_status(company_user_id, status, subscription_path)
    company_user = User.company_users.find(company_user_id)
    upgrade = company_user.service_upgrade == "upgrading"
    update_params = {}
    if upgrade.present?
      if status == "rejected"
        update_params = {
          reason_for_service_rejection: params[:reason],
          service_rejected_at: Time.now,
          service_upgrade: 'rejected'
        }
      else
        update_params = {
          subscription_services: 'Premium',
          subscription_approved: status,
          service_upgrade_approved_at: Time.now,
          service_upgrade: 'approved'
        }
      end
    else
      update_params = {
        subscription_approved: status,
        subscription_approved_at: (Time.now if status == "premium" || status == "basics"),
        reason_for_service_rejection: (params[:reason] if status == "rejected"),
        service_rejected_at: (Time.now if status == "rejected"),
      }
    end
    if upgrade.present?
      redirect_to subscription_path, notice: 'Company User request status has been updated successfully.'
      company_user.update(update_params)
      begin
        UserMailer.subscription_upgrade_notify_user(company_user).deliver_later if params[:status] != "rejected"
       rescue StandardError => e
         Rails.logger.error "Failed to send email: #{e.message}"
       end
    else
      if company_user.update(update_params)
        begin
          UserMailer.send_service_approve_reject_mail(company_user).deliver_later
          UserMailer.account_activation_approved(company_user).deliver_later if status != "rejected"
         rescue StandardError => e
           Rails.logger.error "Failed to send email: #{e.message}"
         end
        redirect_to subscription_path, notice: 'Company User request status has been updated successfully.'
      else
        redirect_to subscription_path, error: 'Company User request status update has been failed.'
      end
    end
  end

  def export_excel_data(users, template)
    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="dashboard_data.xlsx"'
        render template: template
      end
      format.html { render :export_excel }
    end
  end

  def service_filter_helper(company_detail, params) 
    @company_name = params[:companyName].present? ? params[:companyName] : ""
    @search_year = params[:year].present? ? params[:year] : ""
    @analyst = params[:analyst].present? ? params[:analyst] : ""
    @sector_ids = params[:sector_ids] || []
    decoded_sector_names = CGI.unescape(params[:sector_ids] || "")
    sector_names = decoded_sector_names.split(",").map(&:strip).map { |sector_name| Sector.find_by(sector_name: sector_name)&.sector_name }
    @company_detail = company_detail&.order(created_at: :desc)&.where(params[:sector_ids].present? ? { company_sector: sector_names } : {})
    @company_detail = @company_detail&.search_by(params[:companyName]) if params[:companyName].present?
    @company_detail = @company_detail&.by_creation_year(params[:year]) if params[:year].present?
    @company_detail = @company_detail&.where(analyst_user_id: params[:analyst]) if params[:analyst].present?
  end

  def user_role_check
    unless current_user.is_admin? || current_user.is_manager?
      render template: "errors/not_found"
    end
  end

  def deleted_user_restrict
    if current_user.approved? && !current_user.diagonsitics_delete_status.nil? && (current_user.basic_delete_status.nil? && current_user.premium_delete_status.nil? && current_user.subscription_approved.in?(["premium", "basics"]))
      redirect_to peer_benchmarking_path, alert: "Your Diagnostics account has been deleted"
    elsif !current_user.diagonsitics_delete_status.nil? && (!current_user.basic_delete_status.nil? || !current_user.premium_delete_status.nil?)
        sign_out
				flash[:notice] =  "Your account has been deactivated."
				redirect_to new_user_session_path
				return
    elsif !current_user.diagonsitics_delete_status.nil? && (current_user.basic_delete_status.nil? && current_user.premium_delete_status.nil? && !current_user.subscription_approved.in?(["premium", "basics"]))
      sign_out
      flash[:notice] =  "Your account has been deactivated."
      redirect_to new_user_session_path
      return
    end    
  end
end