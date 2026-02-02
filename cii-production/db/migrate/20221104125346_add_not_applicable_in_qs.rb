class AddNotApplicableInQs < ActiveRecord::Migration[7.0]
  def change
    add_column :questionnaire_scores, :not_applicable_status, :integer
  end
end
