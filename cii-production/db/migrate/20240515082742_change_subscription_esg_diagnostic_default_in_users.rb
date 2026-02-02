class ChangeSubscriptionEsgDiagnosticDefaultInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :subscription_esg_diagnostic, from: false, to: true
  end
end
