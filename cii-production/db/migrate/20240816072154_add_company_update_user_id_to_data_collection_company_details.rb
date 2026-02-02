class AddCompanyUpdateUserIdToDataCollectionCompanyDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :data_collection_company_details, :company_update_user_id, :integer, null: true
  end  
end
