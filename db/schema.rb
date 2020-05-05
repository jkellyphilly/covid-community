# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_05_181350) do

  create_table "deliveries", force: :cascade do |t|
    t.string "items"
    t.string "date"
    t.integer "member_id"
    t.integer "volunteer_id"
    t.string "status"
  end

  create_table "members", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "address"
    t.string "phone_number"
    t.string "allergies"
    t.string "password_digest"
    t.string "email"
  end

  create_table "volunteers", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "phone_number"
    t.string "password_digest"
    t.string "email"
  end

end
