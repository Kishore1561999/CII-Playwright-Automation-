class AddColumnsToDataCollectionAnswer < ActiveRecord::Migration[7.0]
  def change
    add_column :data_collection_answers, :company_name, :string
    add_column :data_collection_answers, :hidden_company_name, :string
  end
end
