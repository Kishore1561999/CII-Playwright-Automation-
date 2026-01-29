class RenameBrsrColumnCompanyDetails < ActiveRecord::Migration[7.0]
  def change
    rename_column :data_collection_company_details, :brsr_report, :pdffile
  end
end
