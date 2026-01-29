class AddColumnsToDataCollectionErrorLog < ActiveRecord::Migration[7.0]
  def change
    add_column :data_collection_error_logs, :params_id_user_answers, :jsonb, default: '{}'
    add_column :data_collection_error_logs, :hidden_id_user_answers, :jsonb, default: '{}'
  end
end
