class AddSelectedYearToDataCollectionCompanyDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :data_collection_company_details, :selected_year, :string
  end
end
