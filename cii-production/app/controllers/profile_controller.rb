class ProfileController < ApplicationController
  include MailHelper
  before_action :authenticate_user!
  def edit
    @user = current_user
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update_with_password(user_params)
        send_password_reset_emails(@user, params)
        sign_out @user
        format.html { redirect_to new_user_session_path, notice: 'Your password has been changed successfully.' }
      else
        format.html { render :edit }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end
end
