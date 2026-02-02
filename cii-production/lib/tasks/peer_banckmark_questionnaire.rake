require "roo"

namespace :peer_banckmark_questionnaire do
  desc "Import questionnaire data from spreadsheet"

  task load_peerbenchmark_questionaire_data: :environment do
    include ApplicationHelper
    
    PeerBenchmarkingQuestionnaire.where(version: current_year).delete_all
    file_path = "lib/PeerBenchMarkingQuestionnaire#{current_year}.xlsx"
    data = Roo::Spreadsheet.open(file_path)
    ["Peer Benchmarking"].each_with_index do |sheet_name, sheet_idx|

      data.sheet(sheet_name).each_with_index do |row, idx|
        next if idx == 0
        PeerBenchmarkingQuestionnaire.create!(question_id: row[0], question_name: row[1], question_type: row[2], options: JSON.parse(row[3]), version: current_year )
      end
    end
  end
end
