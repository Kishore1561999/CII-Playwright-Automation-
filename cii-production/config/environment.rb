# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  user_name: ENV['MAILER_USERNAME'],
  password: ENV['MAILER_PASSWORD'],
  # password: Rails.application.credentials.dig(:sendgrid_api_key),
  domain: ENV['MAILER_DOMAIN'],
  address: ENV['MAILER_ADDRESS'],
  port: ENV['MAILER_PORT'],
  authentication: ENV['MAILER_AUTHENTICATION'],
  # authentication: :plain,
  enable_starttls_auto: true
}