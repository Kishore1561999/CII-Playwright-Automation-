# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## User Info
      t.string     :first_name
      t.string     :last_name
      t.string     :mobile
      t.string     :gender
      t.string     :company_name
      t.string     :company_isin_number
      t.string     :company_sector
      t.string     :company_description
      t.string     :company_address_line1
      t.string     :company_address_line2
      t.string     :company_zip
      t.string     :company_country
      t.string     :company_state
      t.string     :company_city
      t.string     :primary_name
      t.string     :primary_email
      t.string     :primary_contact
      t.string     :primary_designation
      t.string     :alternate_name
      t.string     :alternate_email
      t.string     :alternate_contact
      t.string     :alternate_designation
      t.string     :user_status
      t.boolean    :approved
      t.datetime   :approved_at
      t.string     :reason_for_rejection
      t.datetime   :rejected_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :company_isin_number,  unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    add_reference :users, :role, index: true
  end
end
