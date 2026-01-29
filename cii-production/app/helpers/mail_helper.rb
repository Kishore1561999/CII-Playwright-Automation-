module MailHelper
    def send_registration_acknowledgement_emails(resource)
        if resource.subscription_services? && !resource.subscription_esg_diagnostic?
            send_acknowledgement_email(resource, "registration_service_submitted")
            UserMailer.new_service_company_request(resource).deliver_later
        elsif resource.subscription_esg_diagnostic? && !resource.subscription_services?
            send_acknowledgement_email(resource, "registration_submitted")
            UserMailer.send_registration_mail.deliver_later
        else
            send_acknowledgement_email(resource, "registration_submitted")
            send_acknowledgement_email(resource, "registration_service_submitted")
            [UserMailer.new_service_company_request(resource), UserMailer.send_registration_mail].map(&:deliver_later)
        end
    end

    def send_password_reset_emails(user, params)
        if user.is_admin? || user.is_manager? || user.is_analyst?
          UserMailer.password_reset_for_team(user, params).deliver_now
        elsif user.subscription_approved_at? && !user.approved?
          UserMailer.service_password_reset(user).deliver_now
        elsif !user.subscription_approved_at? && user.approved?
          UserMailer.password_change(user).deliver_now
        else
          UserMailer.service_password_reset(user).deliver_now
        end
    end

    private

    def send_acknowledgement_email(resource, template_name)
        UserMailer.send_acknowledgement_mail(resource, template_name).deliver_later
    end
end