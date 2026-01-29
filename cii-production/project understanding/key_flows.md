# Key User Flows and Business Logic

## 1. Assessment Flow
The core functionality is the assessment process for Company Users.
- **Route**: `/company_user/take_assessment` -> `CompanyUser::AssessmentController#take_assessment`
- **Logic**:
    1.  Checks if the user has already submitted the assessment (`current_user.has_assessment_status?`).
    2.  Loads `Questionnaire` questions based on the user's assigned `questionnaire_version_id`.
    3.  Fetches existing `Answer` record if present.
- **Saving**:
    - `save_assessment` endpoint calls `save_answer`.
    - Answers are stored as JSON in the `Answer` model (one row per user per assessment type).
    - `Answers::AnswerService` merges new answers with existing ones.
- **Submission**:
    - `submit_assessment` updates `user_status` to `ASSESSMENT_SUBMITTED`.
    - Triggers emails to CII and the Company User via `UserMailer`.
    - Creates a snapshot/duplicate of the answer for CII (`answer_type: ApplicationRecord::CII_USER`).

## 2. User Registration & Validation
- **Model**: `User`
- **Controller**: `RegistrationsController` (Devise)
- **Validations**:
    - **Company Role**: Requires `company_name`, `company_sector`, `company_address`, `primary_contact` details.
    - **Management Role**: Requires `first_name`, `last_name`, `mobile`.
    - **Uniqueness**: `company_isin_number` must be unique if present.
- **Scopes**:
    - `management_users`: Admin, Analyst, Manager.
    - `company_users`: Users with the Company User role.

## 3. Data Collection & Analysis
- **Roles**: Analyst
- **Flow**:
    - Analysts can initiate data collection for companies.
    - They review submitted data and can "push back" if clarification is needed.
    - Validations likely exist to ensure data consistency before analytics generation.

## 4. Reports & Downloads
- **Controllers**: `DownloadsController`, `WordReportController`
- **Features**:
    - PDF Assessment generation.
    - Excel Score Report download.
    - Word document report generation.
    - Automatic Chart/Graph generation for reports.
