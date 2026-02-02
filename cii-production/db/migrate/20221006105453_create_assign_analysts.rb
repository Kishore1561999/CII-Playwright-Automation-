class CreateAssignAnalysts < ActiveRecord::Migration[7.0]
  def change
    create_table :assign_analysts do |t|
      t.integer   :company_user_id
      t.integer   :analyst_user_id

      t.timestamps
    end
  end
end
