class AddSubscriptionRejectionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :reason_for_service_rejection, :string
    add_column :users, :service_rejected_at, :datetime
  end
end
