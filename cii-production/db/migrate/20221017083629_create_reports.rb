class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.integer   :assign_analyst_id
      

      t.timestamps
    end
  end
end
