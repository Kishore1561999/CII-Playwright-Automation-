class AddVersionColumnToPeerBenchmarkingAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :peer_benchmarking_answers, :version, :integer
  end
end
