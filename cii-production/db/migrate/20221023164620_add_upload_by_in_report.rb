class AddUploadByInReport < ActiveRecord::Migration[7.0]
  def change
    add_column :reports, :upload_by, :string
  end
end
