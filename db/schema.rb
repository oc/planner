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

ActiveRecord::Schema[8.0].define(version: 2026_02_11_155457) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type", null: false
    t.bigint "trackable_id", null: false
    t.bigint "user_id", null: false
    t.string "action"
    t.jsonb "change_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "owner_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "card_type", default: 0, null: false
    t.integer "stage", default: 0, null: false
    t.integer "priority", default: 2, null: false
    t.integer "position"
    t.jsonb "metadata", default: {}, null: false
    t.jsonb "gate_checklist", default: {}, null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_cards_on_owner_id"
    t.index ["parent_id"], name: "index_cards_on_parent_id"
    t.index ["product_id", "card_type"], name: "index_cards_on_product_id_and_card_type"
    t.index ["product_id", "stage", "position"], name: "index_cards_on_product_id_and_stage_and_position"
    t.index ["product_id"], name: "index_cards_on_product_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.bigint "user_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_comments_on_card_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "external_links", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.integer "provider"
    t.string "external_id"
    t.string "external_url"
    t.integer "sync_status"
    t.datetime "last_synced_at"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_external_links_on_card_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.integer "role", default: 1, null: false
    t.boolean "notifications", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_memberships_on_product_id"
    t.index ["user_id", "product_id"], name: "index_memberships_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "scenarios", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.string "title"
    t.text "given"
    t.text "when_clause"
    t.text "then_clause"
    t.integer "status"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_scenarios_on_card_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.string "name", null: false
    t.string "github_username"
    t.string "phone"
    t.string "avatar_url"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github_username"], name: "index_users_on_github_username", unique: true, where: "(github_username IS NOT NULL)"
  end

  add_foreign_key "activities", "users"
  add_foreign_key "cards", "cards", column: "parent_id"
  add_foreign_key "cards", "products"
  add_foreign_key "cards", "users", column: "owner_id"
  add_foreign_key "comments", "cards"
  add_foreign_key "comments", "users"
  add_foreign_key "external_links", "cards"
  add_foreign_key "memberships", "products"
  add_foreign_key "memberships", "users"
  add_foreign_key "scenarios", "cards"
  add_foreign_key "sessions", "users"
end
