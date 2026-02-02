class CreateQuestionnaireVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :questionnaire_versions do |t|
      t.string :versionname
      t.timestamps
    end
  end
end
