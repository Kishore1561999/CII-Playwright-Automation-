class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable, :timeoutable,
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :validatable

  validates_presence_of :company_name, :company_sector, :company_description, :company_address_line1, :company_country, :company_state, :company_city, :company_zip, :primary_name, :primary_email, :primary_contact, :primary_designation, if: :is_company_role?
  validates_presence_of :first_name, :last_name, :mobile, if: :is_management_role?
  validates_uniqueness_of :company_isin_number, :allow_blank => true

  belongs_to :role

  has_one_attached :company_logo
  has_many :comments

  scope :management_users, -> () { where(role_id: [Role.find_by(role_name: ApplicationRecord::ADMIN)&.id, Role.find_by(role_name: ApplicationRecord::ANALYST)&.id, Role.find_by(role_name: ApplicationRecord::MANAGER)&.id]) }
  scope :analyst_users, -> () { where(role_id: Role.find_by(role_name: ApplicationRecord::ANALYST)&.id) }
  scope :company_users, -> () { where(role_id: Role.find_by(role_name: ApplicationRecord::COMPANY_USER)&.id) }
  scope :search_by, -> (search) { where('lower(company_name) LIKE :search', search: "%#{search}%".downcase)}
  scope :by_creation_year, ->(year) { where("EXTRACT(YEAR FROM created_at) = ?", year.to_i) }
  # scope :search_by, -> (search) { where('lower(company_name) LIKE :search OR lower(company_sector) LIKE :search', search: "%#{search}%".downcase)}
  def is_admin?
    self.role.role_name == ApplicationRecord::ADMIN
  end

  def is_analyst?
    self.role.role_name == ApplicationRecord::ANALYST
  end

  def is_company_user?
    self.role.role_name == ApplicationRecord::COMPANY_USER
  end

  def is_manager?
    self.role.role_name == ApplicationRecord::MANAGER
  end

  def is_approved?
    self.approved == ApplicationRecord::TRUE
  end

  def is_rejected?
    self.approved == ApplicationRecord::FALSE
  end

  def has_assessment_status?
    (ApplicationRecord::ASSESSMENT_STATUS).include?(self.user_status)
  end

  def is_management_role?
    self.role_id == Role.find_by(role_name: ApplicationRecord::ADMIN)&.id || self.role_id == Role.find_by(role_name: ApplicationRecord::ANALYST)&.id || self.role_id == Role.find_by(role_name: ApplicationRecord::MANAGER)&.id
  end

  def is_company_role?
    self.role_id == Role.find_by(role_name: ApplicationRecord::COMPANY_USER)&.id
  end

  def approved_or_subscribed?
    approved? || (ApplicationRecord::SUBSCRIPTION).include?(subscription_approved) || ApplicationRecord::RENEW == subscription_approved
  end
end
