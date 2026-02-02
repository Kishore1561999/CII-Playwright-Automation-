class CreateQuestionnaireScores < ActiveRecord::Migration[7.0]
  def change
    create_table :questionnaire_scores do |t|
      t.integer :company_user_id
      t.string  :category_type
      t.string  :question_name
      t.integer  :score
      t.timestamps
    end
  end
end
