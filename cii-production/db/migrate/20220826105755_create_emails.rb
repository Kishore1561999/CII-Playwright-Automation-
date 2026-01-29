class CreateEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :emails do |t|
      t.string :email_title
      t.string :email_content

      t.timestamps
    end
  end
end
