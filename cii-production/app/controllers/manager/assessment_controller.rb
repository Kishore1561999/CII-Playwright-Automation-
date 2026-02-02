class Manager::AssessmentController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:update_assessment, :submit_assessment]

  def view_assessment
    @categories = Category.all
    @company_user = User.find(params[:company_user_id])
    @questions = Questionnaire.by_version_id(@company_user.questionnaire_version_id)
    @answer = Answer.find_by(user_id: params[:company_user_id], answer_type: params[:user_type])
    @user_answers = Answers::AnswerService.aspects_answer_merger(@answer)
    @user_company_id = CompanyScore.find_by(company_user_id: params[:company_user_id])
    @restrict_edit_access = !AssignAnalyst.find_by(company_user_id: params[:company_user_id], analyst_user_id: current_user.id).present? || @company_user.user_status == ApplicationRecord::ASSESSMENT_QC_COMPLETED
  end

  def edit_assessment
    @company_user = User.find(params[:company_user_id])
    if ApplicationRecord::REPORT_DOWNLOAD_ENABLE_STATUS.include?(@company_user.user_status) || params[:user_type] != ApplicationRecord::CII_USER || !AssignAnalyst.find_by(company_user_id: params[:company_user_id], analyst_user_id: current_user.id).present?
      redirect_to manager_company_users_path, notice: "Un-processable request!"
    end
    if @company_user.user_status == ApplicationRecord::ASSESSMENT_VALIDATION_COMPLETED
      new_status = ApplicationRecord::ASSESSMENT_QC_IN_PROGRESS
      @company_user.update(user_status: new_status)
    end
    @categories = Category.all
    @questions = Questionnaire.by_version_id(@company_user.questionnaire_version_id)
    @answer = Answer.find_by(user_id: params[:company_user_id], answer_type: ApplicationRecord::CII_USER)
    @user_answers = Answers::AnswerService.aspects_answer_merger(@answer)
  end

  def fetch_assessment
    @answer = Answer.find_by(user_id: params[:company_user_id], answer_type: ApplicationRecord::CII_USER)
    @user_answers = @answer.present? ? @answer.send(params['aspect_name'].to_sym) : {}
    attachmentHtml = Answers::AnswerService.files_fetch(params[:company_user_id], params[:categoryId], ApplicationRecord::CII_USER)
    render json: { aspect_data: @user_answers, attachments: attachmentHtml }
  end

  def update_assessment
    user = User.find(params[:company_user_id])
    if ApplicationRecord::REPORT_DOWNLOAD_ENABLE_STATUS.include?(user.user_status)
      render json: { error: 'Unprocessable Content' }, status: :unprocessable_entity
    else
      save_answer
      if user.user_status == ApplicationRecord::ASSESSMENT_VALIDATION_COMPLETED || user.user_status == ApplicationRecord::ANALYST_ASSIGNED
        new_status = (user.user_status == ApplicationRecord::ASSESSMENT_VALIDATION_COMPLETED) ? ApplicationRecord::ASSESSMENT_QC_IN_PROGRESS : ApplicationRecord::ASSESSMENT_VALIDATION_IN_PROGRESS
        user.update(user_status: new_status)
      end
    end
  end

  def submit_assessment
    user = User.find(params[:company_user_id])
    if user.user_status == ApplicationRecord::ASSESSMENT_QC_IN_PROGRESS || user.user_status == ApplicationRecord::ASSESSMENT_VALIDATION_IN_PROGRESS
      new_status = (user.user_status == ApplicationRecord::ASSESSMENT_QC_IN_PROGRESS) ? ApplicationRecord::ASSESSMENT_QC_COMPLETED : ApplicationRecord::ASSESSMENT_VALIDATION_COMPLETED
      user.update(user_status: new_status)
    end
    redirect_to manager_company_users_path, notice: "Response has been updated successfully!"
  end

  def add_attachments
    Answers::AnswerService.add_files(params[:company_user_id], params[:category_id], ApplicationRecord::CII_USER, params[:files])
  end

  def remove_attachment
    Answers::AnswerService.remove_file(params[:company_user_id], params[:category_id], ApplicationRecord::CII_USER, params[:fileName])
  end

  private
    def save_answer
      Rails.logger.info "Manager Answered_to #{params[:company_user_id]}"
      answer_exist = Answer.find_by(user_id: params[:company_user_id], answer_type: ApplicationRecord::CII_USER)

      if answer_exist.present?
        answers = Answers::AnswerService.previous_answer_merger(answer_exist, params['aspect_name'], params['user_answers'])
        answer_exist.update(params['aspect_name'].to_sym => answers, submitted_at: DateTime.now)
      else
        Answer.find_by(user_id: params[:company_user_id], answer_type: ApplicationRecord::COMPANY_USER).dup
              .update(answer_type: ApplicationRecord::CII_USER, submitted_at: DateTime.now)
      end

      rescue Exception => e
        Rollbar.error('Manager User Assessment Save', e)
    end
end
