class CompanyUser::AssessmentController < ApplicationController
  include FilterHelper
  before_action :authenticate_user!
  before_action :deleted_user_restrict
  skip_before_action :verify_authenticity_token, only: [:save_assessment, :submit_assessment]

  def take_assessment
    if !current_user.has_assessment_status?
      @categories = Category.all
      @questions = Questionnaire.where(questionnaire_version_id: current_user.questionnaire_version_id).order(id: :asc)
      @answer = Answer.find_by(user_id: current_user.id, answer_type: ApplicationRecord::COMPANY_USER)
      @user_answers = Answers::AnswerService.aspects_answer_merger(@answer)
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "Instructions",
                 page_size: 'A4',
                 template: "company_user/assessment/assessment_instructions",
                 layout: "layouts/pdf",
                 orientation: "Portrait",
                 margin: { top: "0.5in", left: "0.5in", right: "0.5in", bottom: "0.5in" }
        end
      end
    else
      redirect_to company_user_dashboard_path, notice: "Already you have submitted your response"
    end
  end

  def view_assessment
    if current_user.has_assessment_status?
      @categories = Category.all
      @questions = Questionnaire.where(questionnaire_version_id: current_user.questionnaire_version_id).order(id: :asc)
      @answer = Answer.find_by(user_id: current_user.id, answer_type: ApplicationRecord::COMPANY_USER)
      @user_answers = Answers::AnswerService.aspects_answer_merger(@answer)
    else
      redirect_to company_user_dashboard_path, notice: "You didn't submitted your response"
    end
    end

  def fetch_assessment
    @answer = Answer.find_by(user_id: current_user.id, answer_type: ApplicationRecord::COMPANY_USER)
    @user_answers = @answer.present? ? @answer.send(params['aspect_name'].to_sym) : {}
    attachmentHtml = Answers::AnswerService.files_fetch(current_user.id, params[:categoryId], ApplicationRecord::COMPANY_USER)
    render json: { aspect_data: @user_answers, attachments: attachmentHtml }
  end

  def save_assessment
    if current_user.user_status == ApplicationRecord::ASSESSMENT_SUBMITTED
      render json: { error: 'The Assessment has already been submitted' }, status: :unprocessable_entity
    else
      save_answer
    end
  end

  def submit_assessment
    unless current_user.user_status === ApplicationRecord::ASSESSMENT_SUBMITTED
    Answer.find_by(user_id: current_user.id, answer_type: ApplicationRecord::COMPANY_USER).dup
          .update(answer_type: ApplicationRecord::CII_USER, submitted_at: nil)

    current_user.update(user_status: ApplicationRecord::ASSESSMENT_SUBMITTED)
    begin
      UserMailer.send_assessment_submit_mail_to_cii(current_user).deliver_later
      UserMailer.send_assessment_submit_mail_to_company_user(current_user).deliver_later
    rescue StandardError => e
        Rails.logger.error "Failed to send email: #{e.message}"
    end

    # redirect_to company_user_dashboard_path, notice: "Your response has been submitted successfully!"
    end
  end

  def add_attachments
    Answers::AnswerService.add_files(current_user.id, params[:category_id], ApplicationRecord::COMPANY_USER, params[:files])
  end

  def remove_attachment
    Answers::AnswerService.remove_file(current_user.id, params[:category_id], ApplicationRecord::COMPANY_USER, params[:fileName])
  end


  private

  def save_answer
    Rails.logger.info "Company user Answered_to #{current_user.id}"
    answer_exist = Answer.find_by(user_id: current_user.id, answer_type: ApplicationRecord::COMPANY_USER)

    if answer_exist.present?
      answers = Answers::AnswerService.previous_answer_merger(answer_exist, params['aspect_name'], params['user_answers'])
      answer_exist.update(params['aspect_name'].to_sym => answers, submitted_at: DateTime.now)
    else
      Answer.create(user_id: current_user.id, answer_type: ApplicationRecord::COMPANY_USER, params['aspect_name'].to_sym => JSON.parse(params['user_answers']), submitted_at: DateTime.now)
    end

  rescue Exception => e
    Rollbar.error('Company User Assessment Save', e)
  end
end