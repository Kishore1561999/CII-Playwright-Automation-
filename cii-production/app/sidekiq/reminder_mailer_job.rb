require 'sidekiq-scheduler'

class ReminderMailerJob
  include Sidekiq::Worker
  sidekiq_options queue: :default
  
  def perform(*args)
    users = User.company_users.where(subscription_services: ['Premium', 'Basics'])
    
    current_date = Date.today.strftime('%Y/%m/%d')

    users.each do |user|
      next unless user.subscription_approved_at.present?

      expiration_date = user.subscription_approved_at + 1.year - 1.day
      send_date_day_after = (expiration_date + 1.day).strftime('%Y/%m/%d')
      send_date_two_weeks = (expiration_date + 2.weeks).strftime('%Y/%m/%d')
      send_date_day_before = (expiration_date - 1.day).strftime('%Y/%m/%d')
      send_date_one_weeks = (expiration_date - 1.week).strftime('%Y/%m/%d')

      case current_date
      when send_date_day_after
        UserMailer.reminder_payment_after_year(user).deliver_now
      when send_date_two_weeks
        UserMailer.account_expired_after_week(user).deliver_now
      when send_date_day_before
        UserMailer.reminder_payment_day_before_after_year(user).deliver_now
      when send_date_one_weeks
        UserMailer.reminder_payment_week_before_after_year(user).deliver_now
      end
    rescue StandardError => e
      Rails.logger.error("Error processing reminders for user #{user.id}: #{e.message}")
    end
  end
end

