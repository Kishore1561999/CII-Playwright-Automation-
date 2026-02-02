class Questionnaire < ApplicationRecord
    scope :by_version_id, ->(version_id) { where(questionnaire_version_id: version_id).order(id: :asc) } 
end
