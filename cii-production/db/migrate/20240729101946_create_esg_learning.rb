class CreateEsgLearning < ActiveRecord::Migration[7.0]
  def change
    create_table :esg_learnings do |t|
      t.integer :learning_id
      t.integer :company_user_id
      t.integer :approver_user_id
      t.string :status
      t.datetime :approved_at
      t.string :reason_for_rejection
      t.datetime :rejected_at
      t.timestamps
    end
  end
end
