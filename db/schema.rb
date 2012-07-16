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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120713040651) do

  create_table "data_files", :force => true do |t|
    t.string   "digest"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "p_only_creator"
    t.boolean  "p_any_logged_user"
    t.boolean  "p_upon_token_presentation"
    t.string   "token_id"
    t.integer  "creator_id"
    t.integer  "size"
    t.string   "password"
  end

  create_table "permitted_uses", :force => true do |t|
    t.integer "user_id"
    t.integer "data_file_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "enc_passwd"
    t.string   "salt"
    t.boolean  "p_search_all", :default => false
    t.boolean  "p_admin",      :default => false
    t.integer  "quota",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cookie"
    t.datetime "cookie_exp"
  end

end
