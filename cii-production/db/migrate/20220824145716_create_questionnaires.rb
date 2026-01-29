class CreateQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    create_table :questionnaires do |t|
      t.string    :question_id
      t.string    :question_name
      t.string    :question_type
      t.jsonb     :options,       default: '{}'

      t.timestamps
    end

    add_reference :questionnaires, :category, index: true
  end
end
