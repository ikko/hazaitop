class HoboMigration26 < ActiveRecord::Migration
  def self.up
    drop_table :person_saves
    drop_table :org_saves

    create_table :org_histories do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :organization_id
    end
    add_index :org_histories, [:user_id]
    add_index :org_histories, [:organization_id]

    create_table :person_histories do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :person_id
    end
    add_index :person_histories, [:user_id]
    add_index :person_histories, [:person_id]
  end

  def self.down
    create_table "person_saves", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "person_id"
    end

    add_index "person_saves", ["person_id"], :name => "index_person_saves_on_person_id"
    add_index "person_saves", ["user_id"], :name => "index_person_saves_on_user_id"

    create_table "org_saves", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "organization_id"
    end

    add_index "org_saves", ["organization_id"], :name => "index_org_saves_on_organization_id"
    add_index "org_saves", ["user_id"], :name => "index_org_saves_on_user_id"

    drop_table :org_histories
    drop_table :person_histories
  end
end
