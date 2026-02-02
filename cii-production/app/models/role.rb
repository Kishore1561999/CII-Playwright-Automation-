class Role < ApplicationRecord
  scope :management_roles, -> () { where.not(role_name: ApplicationRecord::COMPANY_USER) }
  scope :company_user_role, -> () { where(role_name: ApplicationRecord::COMPANY_USER) }
end
