class RemovePdfFileFromCompanyDetails < ActiveRecord::Migration[7.0]
  def change
    remove_column :data_collection_company_details, :pdffile, :binary
  end
end
