class ApplicationMailer < ActionMailer::Base
  default from: ENV['SENDER_MAIL']
  layout 'mailer'
end
