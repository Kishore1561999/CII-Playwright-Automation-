class AddServiceUpgradeAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :service_upgrade_approved_at, :datetime
    add_column :users, :reason_for_service_upgrade_rejection, :string
    add_column :users, :service_upgrade_rejected_at, :datetime
  end
end
