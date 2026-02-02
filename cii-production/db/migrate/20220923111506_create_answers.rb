class CreateAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers do |t|
      t.integer   :user_id
      t.string    :status
      t.jsonb     :user_answers,    default: '{}'
      t.datetime  :submitted_at

      t.timestamps
    end
  end
end
