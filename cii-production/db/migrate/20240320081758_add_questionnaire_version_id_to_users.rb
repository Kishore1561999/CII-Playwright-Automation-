class AddQuestionnaireVersionIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :questionnaire_version_id, :integer
  end
end
