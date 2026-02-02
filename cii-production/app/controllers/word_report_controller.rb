class WordReportController < ApplicationController
  before_action :authenticate_user!
  # after_action :remove_graph_images, only: [:download_word_document]
  layout 'word', :only => [:download_word_document]

  def upload_chart
    @company_user_id = params[:company_user_id]
    @category_score = CategoryScore.where(company_user_id: params[:company_user_id]).order('score DESC')
    @graph_labels = []
    @graph_values = []

    @category_score.each do |category|
      @graph_labels.append(ApplicationRecord::ASPECT_TYPE[category[:category_type].to_sym])
      @graph_values.append(category[:score])
    end
  end

  def upload_graph_image
    file = params[:image].read
    File.open(File.join("./public/graph_images/score_chart_#{params[:company_user_id]}.jpg"), 'wb') { |f| f.write file }
  end

  def word_document
    @company_user_doc_id = params[:company_user_id]

    if current_user.is_admin? || current_user.is_manager?
      @sector_ids = params[:sector_ids].present? ? params[:sector_ids].split(",") : []
      @company_name = params[:companyName].present? ? params[:companyName] : ""
      @current_user_id = User.find_by(id: current_user.id)&.id
      @analyst_report_ids = AssignAnalyst.find_by(analyst_user_id: current_user.id)&.id
      sector_names = @sector_ids.map { |sector_id| Sector.find(sector_id)&.sector_name }

      if @sector_ids.length > 0
        @company_users = User.company_users.where(company_sector: sector_names).order(created_at: :desc)
      else
        @company_users = User.company_users.order(created_at: :desc)
      end

      if @company_name != ""
        @company_users = @company_users.search_by(@company_name)
      end
      @company_users = @company_users.paginate(:page => params[:page], :per_page => 15)
      if current_user.is_admin?
        render 'admin/company_users/index'
      elsif current_user.is_manager?
        render 'manager/company_users/index'
      end
    end

    if current_user.is_analyst?
      company_user_ids = AssignAnalyst.where(analyst_user_id: current_user.id).pluck(:company_user_id)
      @company_users = User.where(id: company_user_ids).paginate(page: params[:page], per_page: 15)
      render 'analyst/dashboard/index'
    end

  end

  def download_word_document
    @company_user_id = params[:company_user_id]
    @company_score = CompanyScore.find_by(company_user_id: params[:company_user_id])
    @company_details = User.find(params[:company_user_id])

    if @company_details.company_logo.present?
      blob = @company_details.company_logo.blob
      logo_file_name = "company_logo_#{@company_details.id}.jpg"
      fn = Rails.root.join('public', 'word_doc_images', 'company_logos', logo_file_name)

      File.open(fn, "wb+") do |file|
        blob.download { |chunk| file.write(chunk) }
      end
    end

    doc_file_name = "#{@company_details.company_name}_CII_Report.doc"
    @category_score = CategoryScore.where(company_user_id: params[:company_user_id]).order('score DESC')
    @category_score_hash = {}

    @category_score.each do |category|
      @category_score_hash["#{category[:category_type]}"] = category[:score]
    end

    headers['Content-Type'] = "application/vnd.ms-word; charset=UTF-8"
    headers['Content-Disposition'] = "attachment; filename=\"#{doc_file_name}\""
    headers['Cache-Control'] = ""

  end

end
