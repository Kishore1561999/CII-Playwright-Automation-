class Analyst::DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    company_user_ids = AssignAnalyst.where(analyst_user_id: current_user.id).pluck(:company_user_id)
    @company_user_doc_id = params[:doc_id].present? ? params[:doc_id] : 0
    @company_users = User.where(id: company_user_ids).order(created_at: :desc).paginate(page: params[:page] , per_page: 10)
  end

end
