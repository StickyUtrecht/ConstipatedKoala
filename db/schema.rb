# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141116153106) do

  create_table "activities", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "price",        precision: 6, scale: 2
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "committee_id"
  end

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "committee_members", force: true do |t|
    t.integer  "member_id"
    t.integer  "committee_id"
    t.text     "function"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "committee_members", ["member_id", "committee_id"], name: "index_committee_members_on_member_id_and_committee_id", unique: true, using: :btree

  create_table "committees", force: true do |t|
    t.string   "name"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "educations", force: true do |t|
    t.integer  "member_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "study_id",   null: false
    t.integer  "status"
  end

  add_index "educations", ["member_id", "study_id", "start_date"], name: "index_educations_on_member_id_and_study_id_and_start_date", unique: true, using: :btree

  create_table "ideal_transactions", force: true do |t|
    t.string   "uuid",        limit: 16
    t.text     "description"
    t.decimal  "price",                  precision: 6, scale: 2
    t.integer  "member_id"
    t.string   "activities"
    t.string   "issuer",      limit: 8
    t.string   "status",      limit: 9
    t.string   "iban",        limit: 34
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "impressions", force: true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "members", force: true do |t|
    t.string   "first_name"
    t.string   "infix"
    t.string   "last_name"
    t.string   "address"
    t.string   "house_number"
    t.string   "postal_code"
    t.string   "city"
    t.string   "phone_number"
    t.string   "email"
    t.string   "gender",       limit: 1
    t.string   "student_id"
    t.date     "birth_date"
    t.date     "join_date"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", force: true do |t|
    t.integer  "member_id"
    t.integer  "activity_id"
    t.decimal  "price",       precision: 6, scale: 2
    t.boolean  "paid",                                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participants", ["member_id", "activity_id"], name: "index_participants_on_member_id_and_activity_id", unique: true, using: :btree

  create_table "studies", force: true do |t|
    t.string  "name"
    t.string  "code"
    t.boolean "masters"
  end

  create_table "tags", force: true do |t|
    t.integer  "member_id"
    t.integer  "name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["member_id", "name_id"], name: "index_tags_on_member_id_and_name_id", unique: true, using: :btree

  create_table "trigrams", force: true do |t|
    t.string  "trigram",     limit: 3
    t.integer "score",       limit: 2
    t.integer "owner_id"
    t.string  "owner_type"
    t.string  "fuzzy_field"
  end

  add_index "trigrams", ["owner_id", "owner_type", "fuzzy_field", "trigram", "score"], name: "index_for_match", using: :btree
  add_index "trigrams", ["owner_id", "owner_type"], name: "index_by_owner", using: :btree

end
