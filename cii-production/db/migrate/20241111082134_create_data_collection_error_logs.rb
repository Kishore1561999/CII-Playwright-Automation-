class CreateDataCollectionErrorLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :data_collection_error_logs do |t|
      t.string     :company_name
      t.string     :hidden_company_name
      t.integer     :company_id
      t.integer    :hidden_company_id
      t.integer     :user_id

      t.timestamps
    end
  end
end
