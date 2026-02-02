class ChangeScoreColumninQs < ActiveRecord::Migration[7.0]
  def change
    change_column :questionnaire_scores, :score, :decimal
  end
end
