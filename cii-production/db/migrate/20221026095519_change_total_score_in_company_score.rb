class ChangeTotalScoreInCompanyScore < ActiveRecord::Migration[7.0]
  def change
    change_column :company_scores, :total_score, :decimal
  end
end
