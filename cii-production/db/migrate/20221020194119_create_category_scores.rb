class CreateCategoryScores < ActiveRecord::Migration[7.0]
  def change
    create_table :category_scores do |t|
      t.integer :company_user_id
      t.string  :category_type
      t.decimal :score
      t.timestamps
    end
  end
end
