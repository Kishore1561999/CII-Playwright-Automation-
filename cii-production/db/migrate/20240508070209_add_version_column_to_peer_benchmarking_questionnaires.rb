class AddVersionColumnToPeerBenchmarkingQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    add_column :peer_benchmarking_questionnaires, :version, :integer
  end
end
