class CiiElearning < ApplicationRecord
    has_one_attached :videofile
    has_one_attached :thumbnail
    
    scope :search_by, -> (search) { where('lower(title) LIKE :search', search: "%#{search}%".downcase)}
    scope :by_creation_date, ->(date) { where("DATE(created_at) = ?", date.to_date) }
end
