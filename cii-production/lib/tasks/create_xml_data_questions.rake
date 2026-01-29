# frozen_string_literal: true

desc 'Create XmlDataQuestion data from the JSON file'

task create_xml_data_questions: :environment do
  DataCollectionXmlDataQuestion.delete_all
  questions_path = "lib/xml-question.json"
  return puts 'Questions JSON File not found in the location' unless File.exist?(questions_path)

  json_data = JSON.parse(File.read(questions_path))

  json_data.each do |entry|
    # Create a new record for each entry
    DataCollectionXmlDataQuestion.create(
      element: entry['elements'],
      xml_question_name: entry['xml_question_name'],
      cii_question_name: entry['cii_question_name'],
      is_percentage: entry['decimals']
    )
  end

  puts "#{json_data.count} XmlDataQuestion record(s) created!"
end
