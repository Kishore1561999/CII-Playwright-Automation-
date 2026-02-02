class CreateCompanyScores < ActiveRecord::Migration[7.0]
  def change
    create_table :company_scores do |t|
      t.integer :company_user_id
      t.decimal :score
      t.timestamps
    end
  end
end
