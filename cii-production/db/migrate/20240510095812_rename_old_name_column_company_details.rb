class RenameOldNameColumnCompanyDetails < ActiveRecord::Migration[7.0]
  def change
    rename_column :data_collection_company_details, :xml_report, :upload_status
  end
end
