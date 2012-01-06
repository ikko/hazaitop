# -*- encoding : utf-8 -*-
class HoboMigration3 < ActiveRecord::Migration
  def self.up
    drop_table :affairs
    drop_table :articles

    create_table :grade_of_organizations do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :org_grades do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :person_grades do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :grade_of_people do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

  end

  def self.down
    create_table "affairs", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "articles", :force => true do |t|
      t.string   "web"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    drop_table :grade_of_organizations
    drop_table :org_grades
    drop_table :person_grades
    drop_table :grade_of_people

  end
end

