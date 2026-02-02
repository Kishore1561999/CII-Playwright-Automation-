class RemoveAssignAnalystIdInReport < ActiveRecord::Migration[7.0]
  def change
    remove_column :reports, :assign_analyst_id
  end
end
