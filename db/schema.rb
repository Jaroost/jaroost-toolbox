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

ActiveRecord::Schema[7.1].define(version: 2023_10_06_045530) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "hierarchy"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_groups_on_group_id"
    t.index ["hierarchy"], name: "index_groups_on_hierarchy"
  end

  create_table "user_roles", force: :cascade do |t|
    t.string "role_name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.string "uid"
    t.string "provider"
    t.string "avatar_url"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
    t.text "refresh_token"
    t.text "token"
    t.string "locale", default: "en"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vue_grid_preferences_columns", force: :cascade do |t|
    t.integer "index"
    t.string "grid_id"
    t.bigint "user_id"
    t.string "col_id"
    t.integer "order_priority"
    t.boolean "direction"
    t.boolean "is_visible"
    t.integer "width"
    t.string "pin_location"
    t.text "filter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grid_id"], name: "index_vue_grid_preferences_columns_on_grid_id"
    t.index ["user_id"], name: "index_vue_grid_preferences_columns_on_user_id"
  end

end
