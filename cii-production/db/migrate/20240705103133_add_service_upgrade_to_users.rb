class AddServiceUpgradeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :service_upgrade, :string
  end
end
