class PasswordsController < Devise::PasswordsController
  def create
    user_status = User.find_by_email(resource_params[:email])

    if !user_status.present?
      flash[:notice] = "Incorrect information entered, and/or Email ID does no exist."
      redirect_to new_user_password_path
    elsif user_status.approved? || user_status.subscription_approved.in?(["premium", "basics"])
        self.resource = resource_class.send_reset_password_instructions(resource_params)
        yield resource if block_given?

        if successfully_sent?(resource)
          respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
        else
          respond_with(resource)
        end
    else
        flash[:notice] = "Your account is yet to be activated."
        redirect_to new_user_password_path
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      UserMailer.password_change(resource).deliver_now
      flash[:notice] = "Your password has been changed successfully."
      respond_with resource, location: new_user_session_path
    else
      set_minimum_password_length
      respond_with resource
    end
  end
end
