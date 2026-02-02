class Admin::CompanyUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company_user, only: [:edit, :show, :update, :destroy, :update_status]

  def index
    @sector_ids = (params[:sector_ids] || "").split(",").map(&:strip)
    @company_name = params[:companyName].present? ? params[:companyName] : ""
    @search_year = params[:year].present? ? params[:year] : ""
    @current_user_id = User.find_by(id: current_user.id)&.id
    @analyst_report_ids = AssignAnalyst.find_by(analyst_user_id: current_user.id)&.id
    @company_user_doc_id = params[:doc_id].present? ? params[:doc_id] : 0
    sector_names = @sector_ids.map { |sector_id| Sector.find(sector_id)&.sector_name }
    @company_users = User.company_users.where(subscription_esg_diagnostic: true).where(diagonsitics_delete_status: nil)

    @company_users = @company_users.order(created_at: :desc).where(@sector_ids.present? ? { company_sector: sector_names } : {})

    if @company_name != ""
      @company_users = @company_users.search_by(@company_name)
    end

    if @search_year != ""
      @company_users = @company_users.by_creation_year(params[:year]) if params[:year].present?
    end
    @company_users = @company_users.paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @company_user = User.new
  end

  def create
    @company_user = User.new(company_user_params)

    respond_to do |format|
      if @company_user.save
        format.html { redirect_to admin_company_users_path, notice: 'Company User has been created successfully.' }
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
      if @company_user.update(company_user_params)
        format.html { redirect_to admin_company_users_path, notice: 'Company User has been updated successfully.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @company_user.update(diagonsitics_delete_status: ApplicationRecord::DELETE_STATUS, deleted_at: Time.now)
    #@company_user.destroy

    respond_to do |format|
      format.html { redirect_to admin_company_users_path, notice: 'Company User has been deleted successfully.' }
    end
  end

  def update_status
    questionnaire_version_id = QuestionnaireVersion.maximum(:id)
    update_params = {
      approved: params[:status],
      user_status: params[:status] === "true" ? ApplicationRecord::REGISTRATION_APPROVED : ApplicationRecord::REGISTRATION_REJECTED,
      approved_at: params[:status] === "true" ? Time.now : nil,
      reason_for_rejection: params[:status] === "false" ? params[:reason] : nil,
      rejected_at: params[:status] === "false" ? Time.now : nil,
      questionnaire_version_id: params[:status] === "true" ? questionnaire_version_id : nil,
    }
    Rails.logger.info "***update_params***#{@company_user&.id} --- #{update_params} --- #{params} --- #{questionnaire_version_id}"

    if @company_user.update(update_params)
      begin
        UserMailer.send_approve_reject_mail(@company_user).deliver_later
       rescue StandardError => e
         Rails.logger.error "Failed to send email: #{e.message}"
       end
      redirect_to admin_company_users_path, notice: 'Company User request status has been updated successfully.'
    else
      redirect_to admin_company_users_path, error: 'Company User request status update has been failed.'
    end
  end

  def assign_analyst
    @analyst_user = User.find(params[:id])
    company_user_id = params['company_user_id'].split(",")

    company_user_id.each do |user_id|
      assigned_data = AssignAnalyst.find_by(company_user_id: user_id)
      user = User.find(user_id)

      if assigned_data.present?
        if ApplicationRecord::ANALYST_NAME_ASSIGN_ACCESS_STATUS.include?(user.user_status)
          assigned_data.update(analyst_user_id: params[:id], analyst_name_id: params[:id])
        else
          assigned_data.update(analyst_user_id: params[:id])
        end
      else
        AssignAnalyst.create(company_user_id: user_id, analyst_user_id: params[:id], analyst_name_id: params[:id])
      end
      
      unless ApplicationRecord::ANALYST_ASSIGN_STATUS_RESTRICTION.include?(user.user_status)
        user.update(user_status: ApplicationRecord::ANALYST_ASSIGNED)
      end
    end

    begin
      UserMailer.send_assign_mail(@analyst_user).deliver_later
    rescue StandardError => e
       Rails.logger.error "Failed to send email: #{e.message}"
    end

    redirect_to admin_company_users_path, notice: 'Company User has been successfully assigned to Analyst.'
  end

  private

  def set_company_user
    @company_user = User.find(params[:id])
  end

  def company_user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :company_name, :company_isin_number, :company_sector, :company_description, :company_logo, :company_address_line1, :company_address_line2, :company_country, :company_state, :company_city, :company_zip, :primary_name, :primary_email, :primary_contact, :primary_designation, :alternate_name, :alternate_email, :alternate_contact, :alternate_designation, :approved, :role_id)
  end
end
