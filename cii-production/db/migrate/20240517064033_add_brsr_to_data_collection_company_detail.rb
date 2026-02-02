class AddBrsrToDataCollectionCompanyDetail < ActiveRecord::Migration[7.0]
  def change
    add_column :data_collection_company_details, :brsr_report, :binary
  end
end
