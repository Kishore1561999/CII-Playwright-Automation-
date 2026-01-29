class CreateCiiElearning < ActiveRecord::Migration[7.0]
  def change
    create_table :cii_elearnings do |t|
      t.integer :user_id
      t.string :title
      t.integer :no_of_downloads
      t.string :price
      t.string :service
      t.timestamps
    end
  end
end
