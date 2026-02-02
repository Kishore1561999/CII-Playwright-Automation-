class AddNameInEmail < ActiveRecord::Migration[7.0]
  def change
    add_column :emails, :name, :string
  end
end
