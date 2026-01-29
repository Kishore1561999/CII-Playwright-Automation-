# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_08_26_102937) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "answers", force: :cascade do |t|
    t.integer "user_id"
    t.string "status"
    t.jsonb "user_answers", default: "{}"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "answer_type"
    t.jsonb "cg_answers", default: {}
    t.jsonb "be_answers", default: {}
    t.jsonb "rm_answers", default: {}
    t.jsonb "td_answers", default: {}
    t.jsonb "hr_answers", default: {}
    t.jsonb "hc_answers", default: {}
    t.jsonb "em_answers", default: {}
    t.jsonb "sc_answers", default: {}
    t.jsonb "bd_answers", default: {}
    t.jsonb "pr_answers", default: {}
    t.jsonb "ohs_answers", default: {}
    t.jsonb "csr_answers", default: {}
  end

  create_table "assign_analysts", force: :cascade do |t|
    t.integer "company_user_id"
    t.integer "analyst_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "analyst_name_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_type"
  end

  create_table "categories", force: :cascade do |t|
    t.string "category_name"
    t.string "category_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_scores", force: :cascade do |t|
    t.integer "company_user_id"
    t.string "category_type"
    t.decimal "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "not_applicable_status"
  end

  create_table "cii_elearnings", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.integer "no_of_downloads"
    t.string "price"
    t.string "service"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cii_publications", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer "resource_id"
    t.integer "user_id"
    t.string "user_type"
    t.text "comments"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_scores", force: :cascade do |t|
    t.integer "company_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_score"
    t.decimal "avg_score"
  end

  create_table "data_collection_answers", force: :cascade do |t|
    t.integer "company_id"
    t.string "status"
    t.string "sector"
    t.jsonb "user_answers", default: "{}"
    t.integer "version"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_data_collection_answers_on_company_id"
    t.index ["sector"], name: "index_data_collection_answers_on_sector"
    t.index ["version"], name: "index_data_collection_answers_on_version"
  end

  create_table "data_collection_company_details", force: :cascade do |t|
    t.string "company_name"
    t.string "company_isin_number"
    t.string "company_sector"
    t.integer "analyst_user_id"
    t.string "status"
    t.string "upload_status"
    t.integer "create_user_id"
    t.integer "update_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_type"
    t.string "subscription_services"
    t.string "selected_year"
    t.integer "company_update_user_id"
    t.index ["company_sector"], name: "index_data_collection_company_details_on_company_sector"
    t.index ["id"], name: "index_data_collection_company_details_on_id"
    t.index ["status"], name: "index_data_collection_company_details_on_status"
  end

  create_table "data_collection_questionnaires", force: :cascade do |t|
    t.string "question_id"
    t.string "question_name"
    t.string "question_type"
    t.jsonb "options", default: "{}"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_collection_xml_data_questions", force: :cascade do |t|
    t.string "xml_question_name"
    t.string "cii_question_name"
    t.string "element"
    t.boolean "is_percentage", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emails", force: :cascade do |t|
    t.string "email_title"
    t.string "email_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "status"
  end

  create_table "esg_learnings", force: :cascade do |t|
    t.integer "learning_id"
    t.integer "company_user_id"
    t.integer "approver_user_id"
    t.string "status"
    t.datetime "approved_at"
    t.string "reason_for_rejection"
    t.datetime "rejected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "peer_benchmarking_answers", force: :cascade do |t|
    t.integer "user_id"
    t.string "status"
    t.string "sector"
    t.jsonb "user_answers", default: "{}"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "version"
    t.string "admin_analytics_status"
    t.index ["sector"], name: "index_peer_benchmarking_answers_on_sector"
    t.index ["user_id"], name: "index_peer_benchmarking_answers_on_user_id"
    t.index ["version"], name: "index_peer_benchmarking_answers_on_version"
  end

  create_table "peer_benchmarking_questionnaires", force: :cascade do |t|
    t.string "question_id"
    t.string "question_name"
    t.string "question_type"
    t.jsonb "options", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "version"
  end

  create_table "questionnaire_scores", force: :cascade do |t|
    t.integer "company_user_id"
    t.string "category_type"
    t.string "question_name"
    t.decimal "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "not_applicable_status"
  end

  create_table "questionnaire_versions", force: :cascade do |t|
    t.string "versionname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string "question_id"
    t.string "question_name"
    t.string "question_type"
    t.jsonb "options", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.integer "questionnaire_version_id"
    t.index ["category_id"], name: "index_questionnaires_on_category_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_user_id"
    t.string "upload_by"
  end

  create_table "roles", force: :cascade do |t|
    t.string "role_name"
    t.string "role_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sectors", force: :cascade do |t|
    t.string "sector_name"
    t.string "sector_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "mobile"
    t.string "gender"
    t.string "company_name"
    t.string "company_isin_number"
    t.string "company_sector"
    t.string "company_description"
    t.string "company_address_line1"
    t.string "company_address_line2"
    t.string "company_zip"
    t.string "company_country"
    t.string "company_state"
    t.string "company_city"
    t.string "primary_name"
    t.string "primary_email"
    t.string "primary_contact"
    t.string "primary_designation"
    t.string "alternate_name"
    t.string "alternate_email"
    t.string "alternate_contact"
    t.string "alternate_designation"
    t.string "user_status"
    t.boolean "approved"
    t.datetime "approved_at"
    t.string "reason_for_rejection"
    t.datetime "rejected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id"
    t.integer "questionnaire_version_id"
    t.string "company_scale"
    t.boolean "consent_form", default: false
    t.boolean "subscription_esg_diagnostic", default: true
    t.string "subscription_services"
    t.string "pan_no"
    t.string "gst"
    t.string "subscription_approved"
    t.datetime "subscription_approved_at"
    t.string "reason_for_service_rejection"
    t.datetime "service_rejected_at"
    t.string "service_upgrade"
    t.datetime "service_upgrade_approved_at"
    t.string "diagonsitics_delete_status"
    t.string "basic_delete_status"
    t.string "premium_delete_status"
    t.datetime "deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "xml_data_questions", force: :cascade do |t|
    t.string "xml_question_name"
    t.string "cii_question_name"
    t.string "element"
    t.boolean "is_percentage", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
