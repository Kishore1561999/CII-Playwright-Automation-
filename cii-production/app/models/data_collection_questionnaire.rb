class DataCollectionQuestionnaire < ApplicationRecord
    scope :for_version, ->(year) { where(version: year).order(id: :asc) }
end
