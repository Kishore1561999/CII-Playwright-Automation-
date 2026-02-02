class RegistrationsController < Devise::RegistrationsController
  include MailHelper
  skip_before_action :verify_authenticity_token, only: [:isincheck]

  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?

    if resource.persisted?
      begin
       send_registration_acknowledgement_emails(resource)
      rescue StandardError => e
        Rails.logger.error "Failed to send email: #{e.message}"
      end
      flash[:notice] = "Your registration form has been submitted successfully. You will receive notification on approval."
      respond_with resource, location: new_user_session_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end

    rescue Exception => e
      Rollbar.error('New User Registration', e)

  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?

    if resource_updated
      flash[:notice] = "Profile has been updated successfully."
      respond_with resource, location: profile_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def service_upgrade
    if current_user.subscription_services == 'Premium'
      redirect_to peer_benchmarking_path, notice: 'Your plan has already been upgraded.'
    end
  end

  def email_validation
    email = params[:email]
    user = User.where("email = ?", email)
    if user.present?
      render json: {status: 200}
    else
      render json: {status: 409}
    end
  end

  def upgrading
    company_user = User.company_users.find(current_user.id)
    company_user.update(service_upgrade: ApplicationRecord::UPGRADE, updated_at: DateTime.now)
    begin
      [UserMailer.service_upgrade_to_company_user(company_user), UserMailer.service_upgrade_approval_to_team(company_user)].map(&:deliver_now)
     rescue StandardError => e
       Rails.logger.error "Failed to send email: #{e.message}"
     end
    
    redirect_to peer_benchmarking_path, notice: 'You will have access to the Premium subscription services within 24 hours of successful payment.'
  end

  def isincheck
    isin = params[:isin]
    user = User.where("company_isin_number = ?", isin)
    if user.present?
      render json: {status: 200}
    else
      render json: {status: 409}
    end
  end

  def service_renew
  end

  def renew_upgrading
    company_user = User.company_users.find(current_user.id)
    company_user.update(subscription_approved: "renewed", updated_at: DateTime.now)
    redirect_to peer_benchmarking_path, notice: 'Your account will be renewed within 24 hours of successful payment.'
    begin
      [UserMailer.service_account_reactivation(company_user), UserMailer.account_reactivation_request(company_user)].map(&:deliver_now)
     rescue StandardError => e
       Rails.logger.error "Failed to send email: #{e.message}"
     end
    
  end


  protected
    def update_resource(resource, params)
      resource.update_without_password(params)
    end
end
