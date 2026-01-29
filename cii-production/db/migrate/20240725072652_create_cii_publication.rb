class CreateCiiPublication < ActiveRecord::Migration[7.0]
  def change
    create_table :cii_publications do |t|
      t.integer :user_id
      t.string :title
      t.timestamps
    end
  end
end
