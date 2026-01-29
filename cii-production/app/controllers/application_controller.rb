class ApplicationController < ActionController::Base
  # before_action :authenticate_user!, :except => [:states, :cities]
  before_action :configure_permitted_parameters, if: :devise_controller?

  def states
    render json: CS.states(params[:country]).merge(DL: ApplicationRecord::NEW_DELHI).to_json
  end

  def cities
    render json: (params[:state] == 'DL' ? [ApplicationRecord::NEW_DELHI] : CS.cities(params[:state]))
  end

  protected
    def configure_permitted_parameters
      account_attributes = [:first_name, :last_name, :email, :mobile, :company_name, :company_isin_number, :company_sector, :company_scale, :company_description, :company_logo, :company_address_line1, :company_address_line2, :company_country, :company_state, :company_city, :company_zip, :primary_name, :primary_email, :primary_contact, :primary_designation, :alternate_name, :alternate_email, :alternate_contact, :alternate_designation, :approved, :user_status, :role_id, :consent_form, :subscription_esg_diagnostic, :subscription_services, :gst, :pan_no]
      devise_parameter_sanitizer.permit :sign_up, keys: account_attributes
      # devise_parameter_sanitizer.permit :sign_in, keys: [:login, :password]
      devise_parameter_sanitizer.permit :account_update, keys: account_attributes
    end
end
