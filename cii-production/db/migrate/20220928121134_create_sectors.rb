class CreateSectors < ActiveRecord::Migration[7.0]
  def change
    create_table :sectors do |t|
      t.string :sector_name
      t.string :sector_description

      t.timestamps
    end
  end
end
