class CreateDataCollectionXmlDataQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :data_collection_xml_data_questions do |t|
      t.string  :xml_question_name
      t.string  :cii_question_name
      t.string  :element
      t.boolean :is_percentage, default: false
      
      t.timestamps
    end
  end
end
