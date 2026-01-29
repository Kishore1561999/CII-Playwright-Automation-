require 'zip'

class DownloadsController < ApplicationController
  before_action :authenticate_user!
  def process_and_create_zip_file
    attachments = Attachment.find_by(user_id: params[:user_id])&.files
    tmp_user_folder = "tmp/archive_#{params[:user_id]}"
    directory_length_same_as_documents = Dir["#{tmp_user_folder}/*"].length == attachments.length
    FileUtils.mkdir_p(tmp_user_folder) unless Dir.exists?(tmp_user_folder)

    attachments.each do |document|
      filename = document.blob.filename.to_s
      create_tmp_folder_and_store_documents(document, tmp_user_folder, filename) unless directory_length_same_as_documents
      create_zip_from_tmp_folder(tmp_user_folder, filename) unless directory_length_same_as_documents
    end

    send_file(Rails.root.join("#{tmp_user_folder}.zip"), :type => 'application/zip', :filename => "#{params[:company_name]}_#{params[:aspect_name]}_files.zip", :disposition => 'attachment')
    # File.delete("#{tmp_user_folder}.zip")
    # FileUtils.rm_rf(tmp_user_folder)
  end

  def create_tmp_folder_and_store_documents(document, tmp_user_folder, filename)
    File.open(File.join(tmp_user_folder, filename), 'wb') do |file|
      document.download { |chunk| file.write(chunk) }
    end
  end

  def create_zip_from_tmp_folder(tmp_user_folder, filename)
    Zip::File.open("#{tmp_user_folder}.zip", Zip::File::CREATE) do |zf|
      zf.add(filename, "#{tmp_user_folder}/#{filename}")
    end
  end

  def download_excel_score_report
    @company_details = User.find_by(id: params[:company_user_id])
    @company_score = CompanyScore.find_by(company_user_id: params[:company_user_id])
    @category_score = CategoryScore.where(company_user_id: params[:company_user_id])
    @category_score_hash = {}
    @category_na_hash = {}
    @category_score.each do |category|
      @category_score_hash["#{category[:category_type]}"] = category[:score]
      @category_na_hash["#{category[:category_type]}"] = category[:not_applicable_status]
    end

    @governance_na_count = 0
    @environmental_na_count = 0
    @social_na_count = 0
    @governance_na_status = 0
    @environmental_na_status = 0
    @social_na_status = 0

    governance_aspect_categories = ["cg", "rm", "be", "td"]

    governance_aspect_categories.each do |category|
      if @category_na_hash[category] == 1
        @governance_na_count += 1
      end
    end

    em_aspect_categories = ["em", "bd", "pr"]

    em_aspect_categories.each do |category|
      if @category_na_hash[category] == 1
        @environmental_na_count += 1
      end
    end

    social_aspect_categories = ["hr", "hc", "ohs", "csr", "sc"]

    social_aspect_categories.each do |category|
      if @category_na_hash[category] == 1
        @social_na_count += 1
      end
    end

    if @governance_na_count == 4
      @governance_na_status = 1
    end
    if @environmental_na_count == 3
      @environmental_na_status = 1
    end
    if @social_na_count == 5
      @social_na_status = 1
    end

    @governance_div_value = 4 - @governance_na_count
    @environmental_div_value = 3 - @environmental_na_count
    @social_div_value = 5 - @social_na_count

    @questions_hash = {}
    @questionnaire = Questionnaire.where(questionnaire_version_id: @company_details.questionnaire_version_id).order(id: :asc)
    @questionnaire.each do |question|
      @questions_hash["#{(question[:question_id].gsub("-", "_")).downcase}"] = question[:question_name]
    end

    @questionnaire_score = QuestionnaireScore.where(company_user_id: params[:company_user_id])

    if params[:user_type] == 'cii'
      render xlsx: @company_details.company_name+" ESG CII User Score Report", template: 'report/cii_user_report_excel'
    else
      render xlsx: @company_details.company_name+" ESG Score Report", template: 'report/company_user_report_excel'
    end
  end

  def assessment_pdf
    if current_user.present? && current_user.is_management_role?
      @categories = Category.all
      @company_user = User.find(params[:company_user_id])
      @questions = Questionnaire.by_version_id(@company_user.questionnaire_version_id)
      @answer = Answer.find_by(user_id: params[:company_user_id], answer_type: params[:user_type])
      @user_answers = Answers::AnswerService.aspects_answer_merger(@answer)
      @user_company_id = CompanyScore.find_by(company_user_id: params[:company_user_id])
      respond_to do |format|
        format.pdf do
          render pdf: "#{@company_user.company_name}_assessment".parameterize.underscore.capitalize,
                 disposition: 'attachment',
                 page_size: 'A4',
                 template: "layouts/assessment_pdf/pdf_assessment",
                 header: { html: { template: 'layouts/assessment_pdf/pdf_header' } },
                 footer: { html: { template: 'layouts/assessment_pdf/pdf_footer' } },
                 layout: "layouts/pdf",
                 orientation: "Portrait",
                 margin: { top: "0.9in", left: "0.5in", right: "0.5in", bottom: "0.6in" }
        end
      end
    else
      render html: "<h4>Restricted</h4>".html_safe
    end
  end

  def assessment_pdf_attachment
    if current_user.present?
      if current_user.is_management_role?
        file = ActiveStorage::Blob.find_by(id: params[:file_id])
        if file.present?
          send_data file.download, filename: "#{file.filename}"
        else
          render html: "<h4>File not found</h4>".html_safe
        end
      else
        redirect_to company_user_dashboard_path, notice: "you dont have permission to access this file."
      end
    end
  end

end
