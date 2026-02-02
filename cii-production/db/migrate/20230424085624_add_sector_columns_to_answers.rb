class AddSectorColumnsToAnswers < ActiveRecord::Migration[7.0]
  def change
    column_names = [:cg_answers, :be_answers, :rm_answers, :td_answers, :hr_answers, :hc_answers,
                    :em_answers, :sc_answers, :bd_answers, :pr_answers, :ohs_answers, :csr_answers]
    change_table :answers do |t|
      t.string :answer_type
      column_names.each do |column_name|
        t.jsonb  column_name,  default: {}
      end
    end
  end
end
