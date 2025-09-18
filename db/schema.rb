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

ActiveRecord::Schema[8.0].define(version: 2025_09_22_170816) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "permission_files", force: :cascade do |t|
    t.text "description"
    t.bigint "submission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_permission_files_on_submission_id"
  end

  create_table "readers", force: :cascade do |t|
    t.string "name", null: false
    t.string "prefix"
    t.string "readerrole"
    t.string "type"
    t.string "suffix"
    t.string "sunetid"
    t.string "univid"
    t.bigint "submission_id"
    t.integer "position", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "finalreader"
    t.index ["submission_id"], name: "index_readers_on_submission_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "label", null: false
    t.string "description"
    t.datetime "start_date", precision: nil, null: false
    t.datetime "end_date", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.string "druid", null: false
    t.string "name"
    t.string "prefix"
    t.string "suffix"
    t.string "major"
    t.string "degree"
    t.string "etd_type", null: false
    t.string "title"
    t.text "abstract"
    t.string "cclicense"
    t.string "cclicensetype"
    t.string "embargo"
    t.string "external_visibility"
    t.string "sub"
    t.string "univid"
    t.string "sunetid", null: false
    t.string "ps_career"
    t.string "ps_subplan"
    t.string "dissertation_id", null: false
    t.string "provost"
    t.string "degreeconfyr"
    t.string "schoolname"
    t.string "department"
    t.string "readerapproval"
    t.string "readercomment"
    t.string "readeractiondttm"
    t.string "regapproval"
    t.string "regcomment"
    t.string "regactiondttm"
    t.string "documentaccess"
    t.string "submitted_to_registrar"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "submitted_at", precision: nil
    t.datetime "last_registrar_action_at", precision: nil
    t.datetime "last_reader_action_at", precision: nil
    t.datetime "ils_record_updated_at", precision: nil
    t.datetime "accessioning_started_at", precision: nil
    t.string "folio_instance_hrid"
    t.datetime "ils_record_created_at"
    t.string "orcid"
    t.boolean "citation_verified", default: false, null: false
    t.boolean "abstract_provided", default: false, null: false
    t.boolean "dissertation_uploaded", default: false, null: false
    t.boolean "supplemental_files_uploaded", default: false, null: false
    t.boolean "permission_files_uploaded", default: false, null: false
    t.boolean "rights_selected", default: false, null: false
    t.boolean "format_reviewed", default: false, null: false
    t.boolean "sulicense", default: false, null: false
    t.boolean "permissions_provided", default: false, null: false
    t.boolean "supplemental_files_provided", default: false, null: false
    t.index ["dissertation_id"], name: "index_submissions_on_dissertation_id", unique: true
    t.index ["druid"], name: "index_submissions_on_druid", unique: true
  end

  create_table "supplemental_files", force: :cascade do |t|
    t.text "description"
    t.bigint "submission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_supplemental_files_on_submission_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "permission_files", "submissions"
  add_foreign_key "readers", "submissions"
  add_foreign_key "supplemental_files", "submissions"
end
