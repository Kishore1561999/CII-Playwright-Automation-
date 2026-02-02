class Attachment < ApplicationRecord
  has_many_attached :files
end
