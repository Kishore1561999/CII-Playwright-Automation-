class AddSubscriptionApprovedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :subscription_approved, :string
    add_column :users, :subscription_approved_at, :datetime
  end
end
