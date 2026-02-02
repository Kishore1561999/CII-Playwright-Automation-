class AddNewColumnsInusers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_scale, :string
    add_column :users, :consent_form, :boolean, default: false
    add_column :users, :subscription_esg_diagnostic, :boolean, default: false
    add_column :users, :subscription_services, :string
  end
end
