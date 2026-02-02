class RemoveOldColumnsFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :reason_for_service_upgrade_rejection, :string
    remove_column :users, :service_upgrade_rejected_at, :string
  end
end
