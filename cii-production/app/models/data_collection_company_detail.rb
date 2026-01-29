class DataCollectionCompanyDetail < ApplicationRecord
    has_one_attached :xmlfile
    has_one_attached :pdffile
    
    scope :search_by, -> (search) { where('lower(company_name) LIKE :search', search: "%#{search}%".downcase)}
    scope :by_creation_year, ->(year) { where(selected_year: year) }
end
