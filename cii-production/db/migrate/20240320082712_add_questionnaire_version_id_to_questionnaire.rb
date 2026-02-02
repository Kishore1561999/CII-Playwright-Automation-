class AddQuestionnaireVersionIdToQuestionnaire < ActiveRecord::Migration[7.0]
  def change
    add_column :questionnaires, :questionnaire_version_id, :integer
  end
end
