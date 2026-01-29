class Report < ApplicationRecord
  validates_presence_of :upload_by, :company_user_id
  has_one_attached :analyst_report
end