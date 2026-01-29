class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  ADMIN = 'admin'
  ANALYST = 'analyst'
  MANAGER = 'manager'
  COMPANY_USER = 'company_user'
  CII_USER = 'cii_user'
  ASPECT_TYPE = { :cg => 'Corporate Governance', :be => 'Business Ethics', :rm => 'Risk Management', :td => 'Transparency & Disclosure',
                  :hr => 'Human Rights', :hc => 'Human Capital', :ohs => 'Occupational Health & Safety', :csr => 'Corporate Social Responsibility',
                  :em => 'Environmental Management', :sc => 'Supply Chain', :bd => 'Biodiversity', :pr => 'Product Responsibility' }

  TRUE = true
  FALSE = false
  NIL = nil
  SUBSCRIPTION = ["basics", "premium"]
  RENEW = "renewed"
  REJECTED = "rejected"
  APPROVED = "approved"
  CURRENT_YEAR = Time.now.year
  PREVIOUS_YEAR = Time.now.year-1
  TWO_YEARS_BEFORE = Time.now.year-2

  REGISTRATION_SUBMITTED = "Registration submitted"
  REGISTRATION_APPROVED = "Registration approved"
  REGISTRATION_REJECTED = "Registration rejected"
  ASSESSMENT_SUBMITTED = "Assessment submitted"
  ANALYST_ASSIGNED = "Analyst assigned"
  ASSESSMENT_VALIDATION_IN_PROGRESS = "Validation in-progress"
  ASSESSMENT_VALIDATION_COMPLETED = "Validation completed"
  ASSESSMENT_QC_IN_PROGRESS = "Quality check in-progress"
  ASSESSMENT_QC_COMPLETED = "Quality check completed"
  ASSESSMENT_SCORE_GENERATED = "Score card generated"
  ASSESSMENT_REPORT_GENERATED = "Report generated"
  ESG_INQUIRY_DETAILS_TO_CII = "esg_inquiry_details_to_cii"
  WORK_IN_PROGRESS = "wip"
  WORK_SUBMITTED = "submitted"
  PUSH_BACK = "push_back"
  UPGRADE = "upgrading"
  DELETE_STATUS = "Inactive"

  ANALYST_NAME_ASSIGN_ACCESS_STATUS = [
    ANALYST_ASSIGNED,
    ASSESSMENT_VALIDATION_IN_PROGRESS
  ]

  ANALYST_ASSIGN_STATUS_RESTRICTION = [
    ASSESSMENT_VALIDATION_IN_PROGRESS,
    ASSESSMENT_VALIDATION_COMPLETED,
    ASSESSMENT_QC_IN_PROGRESS,
    ASSESSMENT_QC_COMPLETED
  ]

  ANALYST_ANSWER_RESTRICTION_STATUS = [
    ASSESSMENT_VALIDATION_COMPLETED,
    ASSESSMENT_QC_IN_PROGRESS,
    ASSESSMENT_QC_COMPLETED,
    ASSESSMENT_SCORE_GENERATED,
    ASSESSMENT_REPORT_GENERATED
  ]

  REPORT_DOWNLOAD_ENABLE_STATUS = [
    ASSESSMENT_SCORE_GENERATED,
    ASSESSMENT_REPORT_GENERATED
  ]

  ASSESSMENT_STATUS = [
    ASSESSMENT_SUBMITTED,
    ANALYST_ASSIGNED,
    ASSESSMENT_VALIDATION_IN_PROGRESS,
    ASSESSMENT_VALIDATION_COMPLETED,
    ASSESSMENT_QC_IN_PROGRESS,
    ASSESSMENT_QC_COMPLETED,
    ASSESSMENT_SCORE_GENERATED,
    ASSESSMENT_REPORT_GENERATED
  ]

  GENERATE_SCORE_DISABLE_STATUS = [
    REGISTRATION_SUBMITTED,
    REGISTRATION_APPROVED,
    REGISTRATION_REJECTED,
    ASSESSMENT_SUBMITTED,
    ANALYST_ASSIGNED,
    ASSESSMENT_VALIDATION_IN_PROGRESS,
    ASSESSMENT_VALIDATION_COMPLETED,
    ASSESSMENT_QC_IN_PROGRESS,
    ASSESSMENT_SCORE_GENERATED,
    ASSESSMENT_REPORT_GENERATED,
  ]

  CHECKBOX_DISABLE_STATUS = [
    REGISTRATION_SUBMITTED,
    REGISTRATION_APPROVED,
    REGISTRATION_REJECTED,
    ASSESSMENT_SCORE_GENERATED,
    ASSESSMENT_REPORT_GENERATED
  ]
 # Version One
  CORPORATE_GOVERNANCE_Q_NO = ["cg_01", "cg_02", "cg_03", "cg_04", "cg_05", "cg_06", "cg_07", "cg_08"]
  BUSINESS_ETHICS_Q_NO = ["be_01", "be_02", "be_03", "be_04", "be_05", "be_06", "be_07"]
  RISK_MANAGEMENT_Q_NO = ["rm_01", "rm_02", "rm_03", "rm_04", "rm_05", "rm_06"]
  TRANSPARENCY_AND_DISCLOSURE_Q_NO = ["td_01", "td_02", "td_03", "td_04"]
  HUMAN_RIGHTS_Q_NO = ["hr_01", "hr_02", "hr_03", "hr_04", "hr_05", "hr_06", "hr_07", "hr_08", "hr_09", "hr_10"]
  HUMAN_CAPITAL_Q_NO = ["hc_01", "hc_02", "hc_03", "hc_04", "hc_05"]
  OCCUPATIONAL_HEALTH_AND_SAFETY_Q_NO = ["ohs_01", "ohs_02", "ohs_03", "ohs_04", "ohs_05", "ohs_06", "ohs_07", "ohs_08"]
  CSR_Q_NO = ["csr_01", "csr_02", "csr_03", "csr_04", "csr_05", "csr_06"]
  ENVIRONMENTAL_MANAGEMENT_Q_NO = ["em_01", "em_02", "em_03", "em_04", "em_05", "em_06", "em_07", "em_08", "em_09", "em_10", "em_11"]
  SUPPLY_CHAIN_Q_NO = ["sc_01", "sc_02", "sc_03", "sc_04", "sc_05", "sc_06"]
  BIODIVERSITY_Q_NO = ["bd_01", "bd_02", "bd_03", "bd_04", "bd_05", "bd_06", "bd_07"]
  PRODUCT_RESPONSIBILITY_Q_NO = ["pr_01", "pr_02", "pr_03", "pr_04", "pr_05", "pr_06", "pr_07"]

  CATEGORY_WISE_QUESTION_NO = [
    CORPORATE_GOVERNANCE_Q_NO,
    BUSINESS_ETHICS_Q_NO,
    RISK_MANAGEMENT_Q_NO,
    TRANSPARENCY_AND_DISCLOSURE_Q_NO,
    HUMAN_RIGHTS_Q_NO,
    HUMAN_CAPITAL_Q_NO,
    OCCUPATIONAL_HEALTH_AND_SAFETY_Q_NO,
    CSR_Q_NO,
    ENVIRONMENTAL_MANAGEMENT_Q_NO,
    SUPPLY_CHAIN_Q_NO,
    BIODIVERSITY_Q_NO,
    PRODUCT_RESPONSIBILITY_Q_NO
  ]
# Version Two
  CORPORATE_GOVERNANCE_Q_NO_2 = ["cg_01", "cg_02", "cg_03", "cg_04", "cg_05", "cg_06", "cg_07", "cg_08"]
  BUSINESS_ETHICS_Q_NO_2 = ["be_01", "be_02", "be_03", "be_04", "be_05", "be_06", "be_07", "be_08"]
  RISK_MANAGEMENT_Q_NO_2 = ["rm_01", "rm_02", "rm_03", "rm_04", "rm_05", "rm_06", "rm_07"]
  TRANSPARENCY_AND_DISCLOSURE_Q_NO_2 = ["td_01", "td_02", "td_03", "td_04",  "td_05", "td_06"]
  HUMAN_RIGHTS_Q_NO_2 = ["hr_01", "hr_02", "hr_03", "hr_04", "hr_05", "hr_06", "hr_07", "hr_08", "hr_09", "hr_10", "hr_11", "hr_12"]
  HUMAN_CAPITAL_Q_NO_2 = ["hc_01", "hc_02", "hc_03", "hc_04", "hc_05"]
  OCCUPATIONAL_HEALTH_AND_SAFETY_Q_NO_2 = ["ohs_01", "ohs_02", "ohs_03", "ohs_04", "ohs_05", "ohs_06", "ohs_07", "ohs_08"]
  CSR_Q_NO_2 = ["csr_01", "csr_02", "csr_03", "csr_04", "csr_05", "csr_06"]
  ENVIRONMENTAL_MANAGEMENT_Q_NO_2 = ["em_01", "em_02", "em_03", "em_04", "em_05", "em_06", "em_07", "em_08", "em_09", "em_10", "em_11"]
  SUPPLY_CHAIN_Q_NO_2 = ["sc_01", "sc_02", "sc_03", "sc_04", "sc_05", "sc_06"]
  BIODIVERSITY_Q_NO_2 = ["bd_01", "bd_02", "bd_03", "bd_04", "bd_05", "bd_06", "bd_07"]
  PRODUCT_RESPONSIBILITY_Q_NO_2 = ["pr_01", "pr_02", "pr_03", "pr_04", "pr_05", "pr_06", "pr_07", "pr_08", "pr_09", "pr_10", "pr_11"]

  CATEGORY_WISE_QUESTION_NO_2 = [
    CORPORATE_GOVERNANCE_Q_NO_2,
    BUSINESS_ETHICS_Q_NO_2,
    RISK_MANAGEMENT_Q_NO_2,
    TRANSPARENCY_AND_DISCLOSURE_Q_NO_2,
    HUMAN_RIGHTS_Q_NO_2,
    HUMAN_CAPITAL_Q_NO_2,
    OCCUPATIONAL_HEALTH_AND_SAFETY_Q_NO_2,
    CSR_Q_NO_2,
    ENVIRONMENTAL_MANAGEMENT_Q_NO_2,
    SUPPLY_CHAIN_Q_NO_2,
    BIODIVERSITY_Q_NO_2,
    PRODUCT_RESPONSIBILITY_Q_NO_2
  ]

  PEER_BENCHMARK_STEPS = [
    "The subscriber can provide their own data for the peer benchmarking indicators against which the industry averages will be presented. The questionnaire is accessible by clicking on the [PROVIDE_DATA_IMAGE] <strong>Click &amp; Edit</strong> button on the dashboard.",
    "The data can be provided for all indicators, some indicators, or no indicator. It is optional and the analytics can be run without providing any data by simply clicking on the run analytics button.",
    "The questionnaire has an auto save functionality that saves data after every 2 mins. However, a manual save button has also been provided.",
    "The pdf generated can be accessed from Downloads folder on your desktop/ from registered email/ <strong>View report</strong> option on the dashboard.",
    "The subscribers are suggested to re-check the sector for which they want to run analytics. It is set by-default as the sector chosen by the company in the registration form. It can, however, be changed on the dashboard of the Peer benchmarking services.",
    "If the subscriber provides consent to CII team to use their ESG data, the data will only be added to the backend dataset based on which the industry analytics are generated, and their name or data will not be disclosed to any other subscriber.",
    "The subscriber can run peer benchmarking analytics for different sectors using same/ different set of data.",
    "The subscriber can run peer benchmarking analytics numerous times. When accessed to run for the second time, the default data in the questionnaire will be that was provided by the company during the previous run. It can be cleared by clicking on the clear option.",
    "To understand the peer benchmarking analytics and the company performance in detail, please get in touch with us at <a href=\"mailto:Surabhi.singh@cii.in\">Surabhi.singh@cii.in</a>."
  ]  

  NEW_DELHI = ["New Delhi"]


  ASPECT_FOR_ASSESSMENT = { :cg => 'Corporate Governance', :be => 'Business Ethics', :rm => 'Risk Management', :td => 'Transparency & Disclosure',
                            :hr => 'Human Rights', :hc => 'Human Capital', :ohs => 'Occupational Health & Safety', :csr => 'CSR',
                            :em => 'Environmental Management', :sc => 'Supply Chain', :bd => 'Biodiversity', :pr => 'Product Responsbility' }

end
