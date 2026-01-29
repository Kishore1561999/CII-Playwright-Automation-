class AddCompanyUserIdsToReports < ActiveRecord::Migration[7.0]
  def change
    add_column :reports, :company_user_id, :integer
  end
end
