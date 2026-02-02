class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.integer   :resource_id
      t.integer   :user_id
      t.string    :user_type
      t.text   :comments
      t.datetime  :submitted_at

      t.timestamps
    end
  end
end
