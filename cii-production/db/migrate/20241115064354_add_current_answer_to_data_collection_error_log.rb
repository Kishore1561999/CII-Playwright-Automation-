class AddCurrentAnswerToDataCollectionErrorLog < ActiveRecord::Migration[7.0]
  def change
    add_column :data_collection_error_logs, :current_answer, :jsonb, default: '{}'
  end
end
