class AddAvgAndTotalScoreColumnsInCompanyScore < ActiveRecord::Migration[7.0]
  def change
    remove_column :company_scores, :score
    add_column :company_scores, :total_score, :integer
    add_column :company_scores, :avg_score, :decimal
  end
end
