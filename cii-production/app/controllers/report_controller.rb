class ReportController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:report_details_analyst]

    def report_details_analyst
      role_name = Role.find(current_user.role_id)&.role_name
      report = Report.find_by(company_user_id: params[:report][:company_user_id])
      if report.present?
        report.analyst_report.purge
        report.analyst_report.attach(params[:report][:analyst_report])
        report.update(:upload_by => role_name)
      else
        report = Report.create!(upload_by: role_name, company_user_id: params[:report][:company_user_id].to_i, analyst_report: params[:report][:analyst_report])
      end
      if report.upload_by == "manager" || report.upload_by == "admin"
        User.company_users.find(params[:report][:company_user_id].to_i).update(user_status: ApplicationRecord::ASSESSMENT_REPORT_GENERATED)
        @company_user = User.find(params[:report][:company_user_id])

        doc_image_path = File.join("./public/graph_images/score_chart_#{params[:report][:company_user_id]}.jpg")
        logo_image_path = File.join("./public/word_doc_images/company_logos/company_logo_#{params[:report][:company_user_id]}.jpg")

          File.delete(doc_image_path) if File.exist?(doc_image_path)
          File.delete(logo_image_path) if File.exist?(logo_image_path)

        UserMailer.send_report_generated_mail(@company_user).deliver_now
      end
    end

  end