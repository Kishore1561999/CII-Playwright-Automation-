class Admin::EmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_email, only: [:edit, :show, :update, :destroy]

  def index
    email_status = (params[:email_filter] || "").split(",")
    @emails = Email.order(id: :asc).where(params[:email_filter].present? ? { status: email_status } : {})
    @selected_filters = params[:email_filter]&.split(",") || []
  end

  def new
    @email = Email.new
  end

  def create
    @email = Email.new(email_params)

    respond_to do |format|
      if @email.save
        format.html { redirect_to emails_path, notice: 'Email Content has been created successfully.' }
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
      if @email.update(email_params)
        format.html { redirect_to emails_path, notice: 'Email Content has been updated successfully.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @email.destroy

    respond_to do |format|
      format.html { redirect_to emails_path, notice: 'Email Content has been deleted successfully.' }
    end
  end

  private
    def set_email
      @email = Email.find(params[:id])
    end

    def email_params
      params.require(:email).permit(:email_title, :email_content)
    end
end
