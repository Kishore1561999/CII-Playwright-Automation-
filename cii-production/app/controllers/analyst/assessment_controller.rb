class Analyst::AssessmentController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:update_assessment, :submit_assessment]

  def view_assessment
    @categories = Category.all
    @company_user = User.find(params[:company_user_id])
    @questions = Questionnaire.by_version_id(@company_user.questionnaire_version_id)
    @answer = Answer.find_by(user_id: params[:company_user_id], answer_type: params[:user_type])
    @user_answers = Answers::AnswerService.aspects_answer_merger(@answer)
    @user_company_id = CompanyScore.find_by(company_user_id: params[:company_user_id])
  end

  def edit_assessment
    @company_user = User.find(params[:company_user_id])
    if ApplicationRecord::ANALYST_ANSWER_RESTRICTION_STATUS.include?(@company_user.user_status)
      redirect_to analyst_dashboard_path, notice: "Un-processable request!"
    else
    @categories = Category.all
    @questions = Questionnaire.by_version_id(@company_user.questionnaire_version_id)
    @answer = Answer.find_by(user_id: params[:company_user_id], answer_type: ApplicationRecord::CII_USER)
    @user_answers = Answers::AnswerService.aspects_answer_merger(@answer)
    end
  end

  def fetch_assessment
    @answer = Answer.find_by(user_id: params[:company_user_id], answer_type: ApplicationRecord::CII_USER)
    @user_answers = @answer.present? ? @answer.send(params['aspect_name'].to_sym) : {}
    attachmentHtml = Answers::AnswerService.files_fetch(params[:company_user_id], params[:categoryId], ApplicationRecord::CII_USER)
    render json: { aspect_data: @user_answers, attachments: attachmentHtml }
  end

  def update_assessment
    user = User.find(params[:company_user_id])
    if ApplicationRecord::ANALYST_ANSWER_RESTRICTION_STATUS.include?(user.user_status)
      render json: { error: 'Unprocessable Content' }, status: :unprocessable_entity
    else
      save_answer
      user.update(user_status: ApplicationRecord::ASSESSMENT_VALIDATION_IN_PROGRESS)
    end
  end

  def submit_assessment
    User.find(params[:company_user_id]).update(user_status: ApplicationRecord::ASSESSMENT_VALIDATION_COMPLETED)

    redirect_to analyst_dashboard_path, notice: "Response has been updated successfully!"
  end

  def add_attachments
    Answers::AnswerService.add_files(params[:company_user_id], params[:category_id], ApplicationRecord::CII_USER, params[:files])
  end

  def remove_attachment
    Answers::AnswerService.remove_file(params[:company_user_id], params[:category_id], ApplicationRecord::CII_USER, params[:fileName])
  end

  private
  def save_answer
    Rails.logger.info "Analyst Answered_to #{params[:company_user_id]}"
    answer_exist = Answer.find_by(user_id: params[:company_user_id], answer_type: ApplicationRecord::CII_USER)

    if answer_exist.present?
      answers = Answers::AnswerService.previous_answer_merger(answer_exist, params['aspect_name'], params['user_answers'])
      answer_exist.update(params['aspect_name'].to_sym => answers, submitted_at: DateTime.now)
    else
      Answer.find_by(user_id: params[:company_user_id], answer_type: ApplicationRecord::COMPANY_USER).dup
            .update(answer_type: ApplicationRecord::CII_USER, submitted_at: DateTime.now)
    end

    rescue Exception => e
      Rollbar.error('Analyst User Assessment Save', e)
  end
end
