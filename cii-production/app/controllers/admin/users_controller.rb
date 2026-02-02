class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :show, :update, :destroy]

  def index
    @users = User.management_users.where.not(id: current_user.id).order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        begin
          UserMailer.send_account_details(user_params).deliver_later
        rescue StandardError => e
            Rails.logger.error "Failed to send email: #{e.message}"
        end
        format.html { redirect_to users_path, notice: 'User has been created successfully.' }
      else
        format.html { render :new }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'User has been updated successfully.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path, notice: 'User has been deleted successfully.' }
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :mobile, :password, :password_confirmation, :approved, :role_id)
    end
end
