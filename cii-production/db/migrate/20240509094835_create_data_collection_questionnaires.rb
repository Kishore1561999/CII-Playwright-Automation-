class CreateDataCollectionQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    create_table :data_collection_questionnaires do |t|
      t.string    :question_id
      t.string    :question_name
      t.string    :question_type
      t.jsonb     :options,       default: '{}'
      t.integer    :version

      t.timestamps
    end
  end
end
