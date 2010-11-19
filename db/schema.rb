# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101119151251) do

  create_table "information_sources", :force => true do |t|
    t.string   "name"
    t.string   "web"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weight"
  end

  create_table "interorg_relations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "o2o_relation_type_id"
    t.integer  "organization_id"
    t.integer  "related_organization_id"
    t.integer  "information_source_id"
    t.boolean  "mirrored",                :default => false
    t.integer  "interorg_relation_id"
    t.boolean  "needs_sync",              :default => true
    t.boolean  "copied",                  :default => false
  end

  add_index "interorg_relations", ["information_source_id"], :name => "index_interorg_relations_on_information_source_id"
  add_index "interorg_relations", ["interorg_relation_id"], :name => "index_interorg_relations_on_interorg_relation_id"
  add_index "interorg_relations", ["o2o_relation_type_id"], :name => "index_interorg_relations_on_o2o_relation_type_id"
  add_index "interorg_relations", ["organization_id"], :name => "index_interorg_relations_on_organization_a_id"
  add_index "interorg_relations", ["organization_id"], :name => "index_interorg_relations_on_organization_id"
  add_index "interorg_relations", ["related_organization_id"], :name => "index_interorg_relations_on_organization_b_id"
  add_index "interorg_relations", ["related_organization_id"], :name => "index_interorg_relations_on_related_organization_id"

  create_table "interpersonal_relations", :force => true do |t|
    t.string   "name"
    t.date     "start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "p2p_relation_type_id"
    t.integer  "person_a_id"
    t.integer  "person_b_id"
    t.integer  "information_source_id"
    t.integer  "user_id"
    t.date     "end_time"
    t.integer  "value"
  end

  add_index "interpersonal_relations", ["information_source_id"], :name => "index_interpersonal_relations_on_information_source_id"
  add_index "interpersonal_relations", ["p2p_relation_type_id"], :name => "index_interpersonal_relations_on_p2p_relation_type_id"
  add_index "interpersonal_relations", ["person_a_id"], :name => "index_interpersonal_relations_on_person_a_id"
  add_index "interpersonal_relations", ["person_b_id"], :name => "index_interpersonal_relations_on_person_b_id"
  add_index "interpersonal_relations", ["user_id"], :name => "index_interpersonal_relations_on_user_id"

  create_table "o2o_relation_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "weight"
    t.integer  "pair_id"
  end

  add_index "o2o_relation_types", ["pair_id"], :name => "index_o2o_relation_types_on_pair_id"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "street1"
    t.string   "street2"
    t.string   "zip_code"
    t.string   "trade_register_nr"
    t.string   "tax_nr"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "information_source_id"
    t.integer  "user_id"
    t.date     "start_time"
    t.date     "end_time"
  end

  add_index "organizations", ["information_source_id"], :name => "index_organizations_on_information_source_id"
  add_index "organizations", ["user_id"], :name => "index_organizations_on_user_id"

  create_table "p2o_relation_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "weight"
  end

  create_table "p2p_relation_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "weight"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.date     "born_at"
    t.string   "mothers_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "information_source_id"
    t.integer  "user_id"
  end

  add_index "people", ["information_source_id"], :name => "index_people_on_information_source_id"
  add_index "people", ["user_id"], :name => "index_people_on_user_id"

  create_table "person_to_org_relations", :force => true do |t|
    t.string   "name"
    t.date     "start_time"
    t.date     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "p2p_relation_type_id"
    t.integer  "person_id"
    t.integer  "organization_id"
    t.integer  "information_source_id"
    t.integer  "user_id"
    t.integer  "value"
  end

  add_index "person_to_org_relations", ["information_source_id"], :name => "index_person_to_org_relations_on_information_source_id"
  add_index "person_to_org_relations", ["organization_id"], :name => "index_person_to_org_relations_on_organization_id"
  add_index "person_to_org_relations", ["p2p_relation_type_id"], :name => "index_person_to_org_relations_on_p2p_relation_type_id"
  add_index "person_to_org_relations", ["person_id"], :name => "index_person_to_org_relations_on_person_id"
  add_index "person_to_org_relations", ["user_id"], :name => "index_person_to_org_relations_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "invited"
    t.datetime "key_timestamp"
    t.boolean  "editor",                                  :default => false
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end
