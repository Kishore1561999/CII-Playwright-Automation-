class AddAdminAnalyticsStatusToPeerBenchmarkingAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :peer_benchmarking_answers, :admin_analytics_status, :string
  end
end
