class AddNotApplicableInCs < ActiveRecord::Migration[7.0]
  def change
    add_column :category_scores, :not_applicable_status, :integer
  end
end
