class AddPanAndGstToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :pan_no, :string
    add_column :users, :gst, :string
  end
end
