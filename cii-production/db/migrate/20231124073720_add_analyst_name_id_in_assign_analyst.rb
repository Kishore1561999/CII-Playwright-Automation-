class AddAnalystNameIdInAssignAnalyst < ActiveRecord::Migration[7.0]
  def change
    add_column :assign_analysts, :analyst_name_id, :integer
  end
end