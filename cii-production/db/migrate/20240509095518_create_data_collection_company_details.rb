class CreateDataCollectionCompanyDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :data_collection_company_details do |t|
      t.string     :company_name
      t.string     :company_isin_number
      t.string     :company_sector
      t.integer    :analyst_user_id
      t.string     :status
      t.string     :xml_report
      t.integer    :create_user_id
      t.integer    :update_user_id
      
      t.timestamps
    end
  end
end
