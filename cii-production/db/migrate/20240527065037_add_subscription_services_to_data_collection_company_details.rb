class AddSubscriptionServicesToDataCollectionCompanyDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :data_collection_company_details, :subscription_services, :string
  end
end
