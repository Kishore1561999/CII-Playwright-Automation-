class UserMailer < ApplicationMailer
  def send_acknowledgement_mail(resource, template)
    @mail = Email.find_by(name: template)
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource['email'], subject: @mail.email_title)
    end
  end

  def send_registration_mail
    @mail = Email.find_by(name: "new_company_request")
    if @mail.present?
      @email_text = get_email_text(@mail)
      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def send_account_details(resource)
    @mail = Email.find_by(name: "account_created")
    if @mail.present?
      @resource = resource
      role = Role.find(@resource['role_id'])&.role_name
      @content = @mail.email_content
      @content = @content.gsub("{{role}}", role)
      @content = @content.gsub("{{password}}", @resource['password'])
      @content = @content.gsub("{{user_name}}", "#{@resource["first_name"]} #{@resource['last_name']}")
      @content = @content.gsub("{{email}}", @resource['email'])
      mail(to: @resource['email'], subject: @mail.email_title)
    end
  end

  def send_approve_reject_mail(resource)
    @resource = resource
    if @resource.approved == ApplicationRecord::TRUE
      @mail = Email.find_by(name: "registration_approved")
    elsif @resource.approved == ApplicationRecord::FALSE
      @mail = Email.find_by(name: "registration_rejected")
    end
    if @mail.present?
      @email_text = get_email_text(@mail)
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def send_service_approve_reject_mail(resource)
    @resource = resource
    if ApplicationRecord::SUBSCRIPTION.include?(@resource.subscription_approved)
      @mail = Email.find_by(name: "registration_service_approved")
      new_date = @resource.subscription_approved_at + 1.year - 1.day
      @expired_date = new_date.strftime('%Y-%m-%d')
      @subscription_approved_at = @resource.subscription_approved_at.strftime('%Y-%m-%d')
      @email_content = @mail.email_content
                              .gsub('<%= @subscribed_date %>', "<strong>#{@subscription_approved_at}</strong>")
                              .gsub('<%= @expired_date %>', "<strong>#{@expired_date}</strong>")
    elsif @resource.subscription_approved == ApplicationRecord::REJECTED
      @mail = Email.find_by(name: "registration_service_rejected")
      @email_text = get_email_text(@mail)
    end
    if @mail.present?
      @email_text = get_email_text(@mail)
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def send_assessment_submit_mail_to_cii(resource)
    @mail = Email.find_by(name: "assessment_submitted")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def send_assessment_submit_mail_to_company_user(resource)
    @mail = Email.find_by(name: "assessment_submitted_to_cii")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def send_assign_mail(resource)
    @mail = Email.find_by(name: "assessment_assigned_for_verification")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end
  def send_score_card_generated_mail(resource)
    @mail = Email.find_by(name: "score_card_generated")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end
  def send_report_generated_mail(resource)
    @mail = Email.find_by(name: "report_generated")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def get_email_list
    User.where(role_id: [Role.find_by(role_name: ApplicationRecord::ADMIN)&.id, Role.find_by(role_name: ApplicationRecord::MANAGER)&.id]).pluck(:email)
  end

  def get_email_text(mail)
    text = mail.email_content
    text_array = text.split(/\s+/)
    @email_text = text_array.map { |x|
      url = URI.extract(x, ['http', 'https']).join('')
      url.present? ? "<a href=#{url}>#{url}</a>" : x
    }.join(' ')
    return @email_text
  end

  def send_inquiry_email_to_cii(resource)
    @mail = Email.find_by(name: ApplicationRecord::ESG_INQUIRY_DETAILS_TO_CII)
    if @mail.present?
      @resource = resource
      email_content = @mail.email_content
      email_content = email_content.gsub("<%= @company_name %>", @resource['company_name'])
      email_content = email_content.gsub("<%= @company_sector %>", @resource['company_sector'])
      email_content = email_content.gsub("<%= @primary_name %>", @resource['primary_name'])
      email_content = email_content.gsub("<%= @primary_designation %>", @resource['primary_designation'])
      email_content = email_content.gsub("<%= @primary_contact %>", @resource['primary_contact'])

      @formatted_email_content = email_content
      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def send_analytics_report_to_user(resource, pdf_attachment_key, fileName, admin_emails)
    @mail = Email.find_by(name: "send_analytics_report_to_user")
    if @mail.present?
      pdf_attachment = ActiveStorage::Blob.find_signed(pdf_attachment_key)
      attachments[fileName] = pdf_attachment.download
      @resource = resource
      @pdf_attachment = pdf_attachment
      @email_content = @mail.email_content.gsub('<%= @company_sector %>', @resource.company_sector)
      mail(
      to: @resource.email, 
      cc: admin_emails, # Add admin email as CC
      subject: @mail.email_title
    ) 
    end
  end

  def reminder_payment_week_before_after_year(resource)
    @mail = Email.find_by(name: "reminder_payment_week_before_after_year")
    if @mail.present?
      @resource = resource
      new_date = @resource.subscription_approved_at + 1.year - 1.day
      expired_date = new_date.strftime('%Y-%m-%d')
      @email_content = @mail.email_content.gsub('<%= @expired_date %>', expired_date)
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def reminder_payment_day_before_after_year(resource)
    @mail = Email.find_by(name: "reminder_payment_day_before_after_year")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def reminder_payment_after_year(resource)
    @mail = Email.find_by(name: "reminder_payment_after_year")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def account_expired_after_week(resource)
    @mail = Email.find_by(name: "account_expired_after_week")
    if @mail.present?
      @resource = resource
      new_date = @resource.subscription_approved_at + 1.year - 1.day
      @expired_date = new_date.strftime('%Y-%m-%d')
      @company_name = @resource.company_name
      @content = @mail.email_content
      @content = @content.gsub('<%= @expired_date %>', @expired_date)
      @content = @content.gsub('<%= @company_name %>', @company_name)
      @content = @content.gsub("{{company_sector}}", @resource['company_sector'])
      @content = @content.gsub("{{primary_name}}", @resource['primary_name'])
      @content = @content.gsub("{{primary_designation}}", @resource['primary_designation'])
      @content = @content.gsub("{{primary_contact}}", @resource['primary_contact'])
      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def service_account_reactivation(resource)
    @mail = Email.find_by(name: "service_account_reactivation")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def account_reactivation_request(resource)
    @mail = Email.find_by(name: "account_reactivation_request")
    if @mail.present?
      @resource = resource
      @email_content = @mail.email_content.gsub('<%= @company_name %>', @resource.company_name)
      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def service_password_reset(resource)
    @mail = Email.find_by(name: "service_password_reset")
    if @mail.present?
      @email_text = get_email_text(@mail)
      @resource = resource
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def password_reset_for_team(resource, params)
    @mail = Email.find_by(name: "password_reset_for_team")
    if @mail.present?
      @resource = resource
      @new_password = params[:user][:password_confirmation]
      @email_content = @mail.email_content.gsub('<%= @new_password %>', "<strong>#{@new_password}</strong>")
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def new_service_company_request(resource)
    @mail = Email.find_by(name: "new_service_company_request")
    if @mail.present?
      @resource = resource
      email_content = @mail.email_content
      email_content = email_content.gsub("<%= @company_name %>", @resource['company_name'])
      email_content = email_content.gsub("<%= @company_sector %>", @resource['company_sector'])
      email_content = email_content.gsub("<%= @primary_name %>", @resource['primary_name'])
      email_content = email_content.gsub("<%= @primary_designation %>", @resource['primary_designation'])
      email_content = email_content.gsub("<%= @primary_contact %>", @resource['primary_contact'])

      @formatted_email_content = email_content

      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def company_assigned_data_collection(resource, data_collection)
    @mail = Email.find_by(name: "company_assigned_data_collection")
    if @mail.present?
      @resource = resource
      @email_content = @mail.email_content.gsub('<%= @company_name %>', data_collection.company_name)
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def company_pushed_back(resource)
    @mail = Email.find_by(name: "company_pushed_back")
    if @mail.present?
      @resource = User.find_by_id(resource.analyst_user_id)
      @email_content = @mail.email_content.gsub('<%= @company_name %>', "<strong>#{resource.company_name}</strong>")
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def account_activation_approved(resource)
    @mail = Email.find_by(name: "account_activation_approved")
    if @mail.present?
      @resource = resource
      new_date = @resource.subscription_approved_at + 1.year - 1.day
      @expired_date = new_date.strftime('%Y-%m-%d')
      @company_name = @resource.company_name
      @subscription_approved_at = @resource.subscription_approved_at.strftime('%Y-%m-%d')
  
      @email_content = @mail.email_content
                              .gsub('<%= @company_name %>', "<strong>#{@company_name}</strong>")
                              .gsub('<%= @subscribed_date %>', "<strong>#{@subscription_approved_at}</strong>")
                              .gsub('<%= @expired_date %>', "<strong>#{@expired_date}</strong>")
  
      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def password_change(resource)
    @mail = Email.find_by(name: "password_change")
    if @mail.present?
      @resource = resource
      @email_text = get_email_text(@mail)
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def service_upgrade_to_company_user(resource)
    @mail = Email.find_by(name: "service_upgrade_to_company_user")
    if @mail.present?
      @resource = resource
      @email_text = get_email_text(@mail)
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def service_upgrade_approval_to_team(resource)
    @mail = Email.find_by(name: "service_upgrade_approval_to_team")
    if @mail.present?
      @resource = resource
      @email_content = @mail.email_content.gsub('<%= @company_name %>', @resource.company_name)
      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def subscription_upgrade_notify_user(resource)
    @mail = Email.find_by(name: "subscription_upgrade_notify_user")
    if @mail.present?
      @resource = resource
      @email_text = get_email_text(@mail)
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end

  def elearning_download_request(resource, current_user)
    @mail = Email.find_by(name: "elearning_download_request")
    if @mail.present?
      elearning = CiiElearning.find(resource)
      @email_content = @mail.email_content.gsub('<%= elearning_title %>', elearning.title)
      @email_content = @email_content.gsub('<%= company_name %>', current_user.company_name)
      mail(to: get_email_list, subject: @mail.email_title)
    end
  end

  def elearning_approval_success(user_id, learning_id, esglearning_id)
    @esglearning = EsgLearning.find(esglearning_id)
    if @esglearning.status == "approved"
      @mail = Email.find_by(name: "elearning_approval_success")
    elsif @esglearning.status == "rejected"
      @mail = Email.find_by(name: "elearning_approval_rejected")
    end
    if @mail.present?
      @resource = User.find(user_id)
      @elearning = CiiElearning.find(learning_id)
      @email_content = @mail.email_content.gsub('<%= elearning_title %>', @elearning.title)
      mail(to: @resource.email, subject: @mail.email_title)
    end
  end
end
