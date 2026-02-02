class AddDeleteColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :diagonsitics_delete_status, :string
    add_column :users, :basic_delete_status, :string
    add_column :users, :premium_delete_status, :string
    add_column :users, :deleted_at, :datetime
  end
end
