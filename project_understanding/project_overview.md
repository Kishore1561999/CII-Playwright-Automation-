# Project Overview

## 1. Introduction
This project is a web-based **ESG (Environmental, Social, and Governance) Assessment Platform**. It allows companies to register, undergo assessments via questionnaires, and receive scores/reports. It also includes features for peer benchmarking, data collection, and administrative management.

## 2. Technology Stack
- **Backend**: Ruby 3.1.2, Rails 7.0.3
- **Database**: PostgreSQL
- **Frontend**: Webpacker, jQuery, Bootstrap, Toastr
- **Server**: Puma
- **Background Jobs**: Sidekiq, Redis
- **Testing**: Capybara, Selenium WebDriver

## 3. Key Dependencies
- `devise`: Authentication
- `wicked_pdf` / `wkhtmltopdf-binary`: PDF generation
- `caxlsx` / `roo`: Excel export/import
- `city-state`: Address management
- `rollbar`: Error tracking

## 4. User Roles
The application defines four primary roles (managed via `Role` model and `User` scopes):
1.  **Company User**: The end-user representing a company. They take assessments, view dashboards, and access reports.
2.  **Analyst**: Responsible for reviewing company data, managing data collection, and verifying assessments.
3.  **Manager**: Oversees company users and assessments, with more privileges than a standard company user but less than an admin.
4.  **Admin (ESG Admin)**: Full system access, including generic user management, master data creation (E-learning, Publications), and overriding assessment statuses.

## 5. Directory Structure Highlights
- `app/models`: Contains business entities. Key models: `User`, `Questionnaire`, `Answer`, `CompanyScore`.
- `app/controllers`: Organized by user scopes (`admin`, `analyst`, `company_user`, `manager`, `service`).
- `app/services`: Incorporates logic like `Answers::AnswerService` to handle complex answer merging and file attachment logic.
- `app/views`: View templates corresponding to controllers.
