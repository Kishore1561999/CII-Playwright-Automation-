class AddUserTypesToAttachments < ActiveRecord::Migration[7.0]
  def change
    change_table :attachments do |t|
      t.string :user_type
    end
  end
end
