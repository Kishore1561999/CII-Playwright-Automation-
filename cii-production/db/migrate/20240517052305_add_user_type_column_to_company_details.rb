class AddUserTypeColumnToCompanyDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :data_collection_company_details, :user_type, :string
  end
end
