class Email < ApplicationRecord
  validates_presence_of :email_title, :email_content
end
