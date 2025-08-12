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

ActiveRecord::Schema[8.0].define(version: 2025_08_08_233858) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  create_table "character_traits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "character_id", null: false
    t.string "trait_type", limit: 50
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_traits_on_character_id"
  end

  create_table "characters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "name"
    t.string "alternate_names", default: [], array: true
    t.string "tags", limit: 50, default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alternate_names"], name: "index_characters_on_alternate_names", using: :gin
    t.index ["name"], name: "index_characters_on_name"
    t.index ["tags"], name: "index_characters_on_tags", using: :gin
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "characters_conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "conversation_id", null: false
    t.uuid "character_id", null: false
    t.index ["character_id"], name: "index_characters_conversations_on_character_id"
    t.index ["conversation_id", "character_id"], name: "index_characters_conversations_on_conversation_and_user", unique: true
    t.index ["conversation_id"], name: "index_characters_conversations_on_conversation_id"
  end

  create_table "conversation_facts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "conversation_id", null: false
    t.string "fact", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversation_facts_on_conversation_id"
  end

  create_table "conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.uuid "persona_id", null: false
    t.string "tags", limit: 50, default: [], array: true
    t.boolean "assistant", default: true
    t.text "scenario", null: false
    t.text "initial_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["persona_id"], name: "index_conversations_on_persona_id"
    t.index ["tags"], name: "index_conversations_on_tags", using: :gin
  end

  create_table "personas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "name"
    t.text "description"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_personas_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "email", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_id"
    t.string "avatar_url"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github_id"], name: "index_users_on_github_id", unique: true
  end

  add_foreign_key "character_traits", "characters"
  add_foreign_key "characters", "users"
  add_foreign_key "characters_conversations", "characters"
  add_foreign_key "characters_conversations", "conversations"
  add_foreign_key "conversation_facts", "conversations"
  add_foreign_key "conversations", "personas"
  add_foreign_key "personas", "users"
end
