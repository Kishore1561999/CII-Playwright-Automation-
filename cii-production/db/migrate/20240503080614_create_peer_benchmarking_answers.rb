class CreatePeerBenchmarkingAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :peer_benchmarking_answers do |t|
      t.integer   :user_id
      t.string    :status
      t.string    :sector
      t.jsonb     :user_answers,    default: '{}'
      t.datetime  :submitted_at

      t.timestamps
    end
  end
end
