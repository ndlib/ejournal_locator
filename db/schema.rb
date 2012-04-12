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

ActiveRecord::Schema.define(:version => 20120412191815) do

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "user_type"
  end

  create_table "categories", :force => true do |t|
    t.string   "title"
    t.integer  "parent_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "journal_categories", :force => true do |t|
    t.integer  "journal_id"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "journal_categories", ["category_id"], :name => "index_journal_categories_on_category_id"
  add_index "journal_categories", ["journal_id"], :name => "index_journal_categories_on_journal_id"

  create_table "journals", :force => true do |t|
    t.string   "sfx_id",          :limit => 20
    t.string   "issn",            :limit => 8
    t.string   "alternate_issn",  :limit => 8
    t.string   "title"
    t.string   "alternate_title"
    t.string   "display_title"
    t.string   "publisher_name"
    t.string   "publisher_place"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "journals", ["sfx_id"], :name => "index_journals_on_sfx_id"

  create_table "searches", :force => true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "user_type"
  end

  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

end
