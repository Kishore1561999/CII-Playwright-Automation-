class CreateDataCollectionAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :data_collection_answers do |t|
      t.integer   :company_id
      t.string    :status
      t.string    :sector
      t.jsonb     :user_answers,    default: '{}'
      t.integer   :version
      t.datetime  :submitted_at
      
      t.timestamps
    end
  end
end
