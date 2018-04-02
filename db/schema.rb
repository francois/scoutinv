# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_04_02_020351) do

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "slug", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "domain_events", force: :cascade do |t|
    t.string "model_type", null: false
    t.bigint "model_id", null: false
    t.string "type", null: false
    t.jsonb "data", null: false
    t.jsonb "metadata", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_type", "model_id"], name: "index_domain_events_on_model_type_and_model_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "title", null: false
    t.text "description"
    t.date "start_on", null: false
    t.date "end_on", null: false
    t.string "slug", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_events_on_group_id"
    t.index ["slug"], name: "index_events_on_slug", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_groups_on_slug", unique: true
  end

  create_table "member_sessions", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_member_sessions_on_member_id"
  end

  create_table "members", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "slug", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["group_id"], name: "index_members_on_group_id"
    t.index ["slug"], name: "index_members_on_slug", unique: true
  end

  create_table "notes", force: :cascade do |t|
    t.string "parent_type", null: false
    t.bigint "parent_id", null: false
    t.bigint "author_id", null: false
    t.text "body", null: false
    t.string "slug", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_notes_on_author_id"
    t.index ["parent_type", "parent_id"], name: "index_notes_on_parent_type_and_parent_id"
    t.index ["slug"], name: "index_notes_on_slug", unique: true
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id", "category_id"], name: "index_product_categories_on_product_id_and_category_id", unique: true
    t.index ["product_id"], name: "index_product_categories_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "slug", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "aisle"
    t.text "shelf"
    t.text "unit"
    t.index ["group_id"], name: "index_products_on_group_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "event_id", null: false
    t.date "returned_on"
    t.string "slug", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_reservations_on_event_id"
    t.index ["product_id", "event_id"], name: "index_reservations_on_product_id_and_event_id", unique: true
    t.index ["product_id"], name: "index_reservations_on_product_id"
    t.index ["slug"], name: "index_reservations_on_slug", unique: true
  end

  add_foreign_key "events", "groups"
  add_foreign_key "member_sessions", "members"
  add_foreign_key "members", "groups"
  add_foreign_key "notes", "members", column: "author_id"
  add_foreign_key "product_categories", "categories"
  add_foreign_key "product_categories", "products"
  add_foreign_key "products", "groups"
  add_foreign_key "reservations", "events"
  add_foreign_key "reservations", "products"
end
