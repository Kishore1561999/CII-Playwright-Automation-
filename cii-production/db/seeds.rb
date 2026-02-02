# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

pp "------------------------------"
pp "Creating Role"

Role.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!("roles")

Role.find_or_create_by(role_name: "admin")
Role.find_or_create_by(role_name: "analyst")
Role.find_or_create_by(role_name: "company_user")
Role.find_or_create_by(role_name: "manager")

pp "------------------------------"
pp "Creating Category"

Category.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!("categories")

Category.find_or_create_by(category_name: "Corporate Governance")
Category.find_or_create_by(category_name: "Business Ethics")
Category.find_or_create_by(category_name: "Risk Management")
Category.find_or_create_by(category_name: "Transparency & Disclosure")
Category.find_or_create_by(category_name: "Human Rights")
Category.find_or_create_by(category_name: "Human Capital")
Category.find_or_create_by(category_name: "Occupational Health & Safety")
Category.find_or_create_by(category_name: "CSR")
Category.find_or_create_by(category_name: "Environmental Management")
Category.find_or_create_by(category_name: "Supply Chain")
Category.find_or_create_by(category_name: "Biodiversity")
Category.find_or_create_by(category_name: "Product Responsbility")

pp "------------------------------"
pp "Creating Sectors"

Sector.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!("sectors")

Sector.find_or_create_by(sector_name: "Automobiles & Auto Components")
Sector.find_or_create_by(sector_name: "Capital Goods")
Sector.find_or_create_by(sector_name: "Chemicals")
Sector.find_or_create_by(sector_name: "Consumer Durables")
Sector.find_or_create_by(sector_name: "Consumer Services")
Sector.find_or_create_by(sector_name: "Construction Materials")
Sector.find_or_create_by(sector_name: "Constructions")
Sector.find_or_create_by(sector_name: "Diversified")
Sector.find_or_create_by(sector_name: "FMCG")
Sector.find_or_create_by(sector_name: "Financial Services")
Sector.find_or_create_by(sector_name: "Forest Materials")
Sector.find_or_create_by(sector_name: "Healthcare")
Sector.find_or_create_by(sector_name: "Information Technology")
Sector.find_or_create_by(sector_name: "Media, Entertainment & Publication")
Sector.find_or_create_by(sector_name: "Metals & Mining")
Sector.find_or_create_by(sector_name: "Oil, Gas & Consumablefuels")
Sector.find_or_create_by(sector_name: "Power")
Sector.find_or_create_by(sector_name: "Realty")
Sector.find_or_create_by(sector_name: "Services")
Sector.find_or_create_by(sector_name: "Textiles")
Sector.find_or_create_by(sector_name: "Telecommunications")
Sector.find_or_create_by(sector_name: "Utilities")


pp "------------------------------"
pp "Creating Mail Templates"

Email.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!("emails")

#Esg diagnostics email
Email.find_or_create_by(name: "password_change", email_title: "Password Reset", status: "esg_diagnostics", email_content: "We're contacting you to notify you that your password has been changed.")
Email.find_or_create_by(name: "account_created", email_title: "Account created successfully", status: "esg_diagnostics", email_content: "We are contacting you to notify that your account has been created successfully. Please find your login credentials below. Click #{ ENV['APPLICATION_URL'] } here to login now.<br>
   Role: {{role}}<br>
   Password: {{password}}<br>
   UserName: {{user_name}}<br>
   Email: {{email}}"
)
Email.find_or_create_by(name: "new_company_request", email_title: "New Company Request received", status: "esg_diagnostics", email_content: "You have received a new request from a company. Click #{ ENV['APPLICATION_URL'] } here to view details.")
Email.find_or_create_by(name: "registration_submitted", email_title: "Registration submitted", status: "esg_diagnostics", email_content: "We are contacting you to notify that your request has been submitted successfully. You will receive notification on approval.")
Email.find_or_create_by(name: "registration_approved", email_title: "Registration Approved", status: "esg_diagnostics", email_content: "We are contacting you to notify that your Registration on CII CESD portal has been approved. You can now login to our #{ ENV['APPLICATION_URL'] } portal to proceed")
Email.find_or_create_by(name: "registration_rejected", email_title: "Registration Rejected", status: "esg_diagnostics", email_content: "We are contacting you to notify you that your Registration on CII CESD has been Rejected.")
Email.find_or_create_by(name: "assessment_submitted", email_title: "Assessment Submitted", status: "esg_diagnostics",  email_content: "New Assessment request has been received .")
Email.find_or_create_by(name: "assessment_submitted_to_cii", email_title: "Assessment Submitted To CII", status: "esg_diagnostics",  email_content: "Your assessment has been successfully submitted to CII CESD . You will be notified upon verification")
Email.find_or_create_by(name: "assessment_assigned_for_verification", email_title: "Assessment Assigned for Verification", status: "esg_diagnostics",  email_content: "New Assessment has been assigned to you for Validation .")
Email.find_or_create_by(name: "score_card_generated", email_title: "Score card Generated", status: "esg_diagnostics",  email_content: "We are contacting to notify you that your score card has been generated . Please login to #{ ENV['APPLICATION_URL'] } portal to view the score card")
Email.find_or_create_by(name: "report_generated", email_title: "Report Generated", status: "esg_diagnostics",  email_content: "We are contacting you to notify that, your CII CESD Report has been generated. Please click on the link below to view the same. #{ ENV['APPLICATION_URL'] }")

#Subscription service email
Email.find_or_create_by(name: "registration_service_submitted", email_title: "Successful Registration", status: "basic_premium", email_content: "We are contacting you to notify that you have successfully registered for our ESG subscription services. Your subscription account will be activated within 24 hours of successful payment.")
Email.find_or_create_by(name: "registration_service_approved", email_title: "ESG Subscription Account Activation", status: "basic_premium", email_content: "We are contacting you to notify that your ESG subscription account has been activated.<br>
   Validity Period: <%= @subscribed_date %> to <%= @expired_date %>.<br>
   Login on our <a href=#{ ENV['APPLICATION_URL'] }>ESG subscription portal</a> to access the services.")
Email.find_or_create_by(name: "registration_service_rejected", email_title: "ESG Subscription Account Rejected",  status: "basic_premium", email_content: 'Your subscription request has been denied due to failed payments. Please contact CII team <a href="mailto:sustainableplus@cii.in">@Sustainableplus</a> for any query.')
Email.find_or_create_by(name: "esg_inquiry_details_to_cii", email_title: "Enquiry Details",  status: "basic_premium", email_content: "Enquired about the ESG Diagnostics<br>
    Name of Company: <%= @company_name %><br>
    Company Sector: <%= @company_sector %><br>
    Contact Name: <%= @primary_name %><br>
    Designation: <%= @primary_designation %><br>
    Contact Number: <%= @primary_contact %>")
Email.find_or_create_by(name: "send_analytics_report_to_user", email_title: "ESG Peer Benchmarking Analytics", status: "basic_premium", email_content: "We are contacting you to notify that your ESG Peer Benchmarking Analytics report has been successfully generated for <%= @company_sector %> sector. Please Find it in attachment. You can also login on our <a href=#{ ENV['APPLICATION_URL'] }>ESG subscription portal</a> to access the latest report generated.")
Email.find_or_create_by(name: "reminder_payment_week_before_after_year", email_title: "Reminder to make payment after one year", status: "basic_premium", email_content: "We are contacting you to notify that your subscription to CII-CESD ESG services, for a term of 1 year, ends on <%= @expired_date %>. To continue accessing our services, please renew the payment on the profile page of  #{ ENV['APPLICATION_URL'] } portal. ")
Email.find_or_create_by(name: "reminder_payment_day_before_after_year", email_title: "Reminder to make payment after one year", status: "basic_premium", email_content: "We are contacting you to notify that your subscription to CII-CESD ESG services, for a term of 1 year, ends tomorrow. To continue accessing our services, please renew the payment on the #{ ENV['APPLICATION_URL'] } portal.")
Email.find_or_create_by(name: "reminder_payment_after_year", email_title: "Reminder to make payment after one year", status: "basic_premium", email_content: "We are contacting you to notify that your subscription to CII-CESD ESG services, for a term of 1 year, has expired. To continue accessing our services, please renew the payment on the #{ ENV['APPLICATION_URL'] } portal.")
Email.find_or_create_by(
    name: "service_account_reactivation",
    email_title: "Account Reactivation",
    status: "basic_premium",
    email_content: "We are contacting you to notify that you are in the process of renewing your subscription to our ESG services. Click here to access the services #{ ENV['APPLICATION_URL'] } portal. Please contact us on <a href=\"mailto:sustainableplus@cii.in\">@Sustainableplus</a> if your account is not reactivated within 24 hours of successful payment."
)
Email.find_or_create_by(name: "service_password_reset", email_title: "Password Reset", status: "basic_premium", email_content: "We are contacting you to notify that you have successfully reset your password for your ESG subscription services account.")
Email.find_or_create_by(name: "service_upgrade_to_company_user", email_title: "Subscription Upgrade", status: "basic_premium", email_content: "This is to notify you that you have applied for upgrade for subscription services from basic to premium. You will have access to the Premium subscription services within 24 hours of successful payment.")
Email.find_or_create_by(name: "subscription_upgrade_notify_user", email_title: "Subscription Upgraded Successfully", status: "basic_premium", email_content: "Your account on our ESG portal has been upgraded from Basic subscription to Premium subscription. ")

#Admin manager
Email.find_or_create_by(name: "account_expired_after_week", email_title: "Subscribers account expired", status: "admin_manager", email_content: "Account for company, <%= @company_name %>, has expired on <%= @expired_date %><br>
    Name of Company: <%= @company_name %><br>
    Company Sector: {{company_sector}}<br>
    Contact Name: {{primary_name}}<br>
    Designation: {{primary_designation}}<br>
    Contact Number: {{primary_contact}}"
)
Email.find_or_create_by(name: "account_activation_approved", email_title: "ESG Subscription Account Activation", status: "admin_manager", email_content: "ESG subscription account for company, <%= @company_name %>, has been activated for a period of 1 year.<br>
Validity Period: <%= @subscribed_date %> to <%= @expired_date %>")
Email.find_or_create_by(name: "account_reactivation_request", email_title: "Account Reactivation Request", status: "admin_manager", email_content: "Account renewal request received from company, <%= @company_name %>. Please visit the #{ ENV['APPLICATION_URL'] } portal to approve the access.")
Email.find_or_create_by(
    name: "new_service_company_request",
    email_title: "Company Registration",
    status: "admin_manager",
    email_content: "New company registered for ESG subscription services:<br>
    Name of Company: <%= @company_name %><br>
    Company Sector: <%= @company_sector %><br>
    Contact Name: <%= @primary_name %><br>
    Designation: <%= @primary_designation %><br>
    Contact Number: <%= @primary_contact %>"
)
Email.find_or_create_by(name: "service_upgrade_approval_to_team", email_title: "Subscription Upgrade Approval Request", status: "admin_manager", email_content: "An application to upgrade services from Basic to premium has been received. Company Name: <%= @company_name %>. Please visit the Premium subscription dashboard to approve or deny the application.")

#all users
Email.find_or_create_by(name: "password_reset_for_team", email_title: "Password Reset", status: "admin_manager", email_content: "You have reset your password for the ESG portal.The new password is: <%= @new_password %>")
Email.find_or_create_by(name: "company_assigned_data_collection", email_title: "Company Assigned", status: "admin_manager", email_content: "New company, <%= @company_name %>, has been assigned to you for data collection on ESG portal.")
Email.find_or_create_by(name: "company_pushed_back", email_title: "Company Pushed Back", status: "admin_manager", email_content: "Company, <%= @company_name %>, submitted through your account has been pushed back for review. Please review and submit the data again on portal.")
Email.find_or_create_by(name: "elearning_download_request", email_title: "E-learning Download Request", status: "admin_manager", email_content: "A New Request for E-Learning Video Download <br>
    Title: <b><%= elearning_title %></b> <br>
    Company Name <b><%= company_name %></b")
Email.find_or_create_by(name: "elearning_approval_success", email_title: "E-learning Approved Successfully", status: "basic_premium", email_content: "We are contacting you to notify you that your request for E-Learning download was approved. You will download the E-Learning video from My Downloads. <br>
    Title: <b><%= elearning_title %></b>")
Email.find_or_create_by(name: "elearning_approval_rejected", email_title: "E-learning Approval Rejected", status: "basic_premium", email_content: "We are contacting you to notify you that your request for an E-Learning download has been rejected. <br>
    Title: <b><%= elearning_title %></b>")
pp "------------------------------"
pp "Creating User"

# User.delete_all
# ActiveRecord::Base.connection.reset_pk_sequence!("users")

# User.create!(first_name: "Surabhi", last_name: "Singh", email: "surabhi.singh@cii.in", mobile: "9958582768", password: "surabhi@cii", role_id: Role.find_by(role_name: ApplicationRecord::ADMIN)&.id, approved: true)
