# -*- encoding : utf-8 -*-
class HoboMigration4 < ActiveRecord::Migration
  def self.up
    drop_table :grade_of_organizations
    drop_table :grade_of_people

    create_table :organization_grade_assocs do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :person_grade_assocs do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :person_id
      t.integer  :person_grade_id
    end
    add_index :person_grade_assocs, [:person_id]
    add_index :person_grade_assocs, [:person_grade_id]

  end

  def self.down
    create_table "grade_of_organizations", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "grade_of_people", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    drop_table :organization_grade_assocs
    drop_table :person_grade_assocs

  end
end

