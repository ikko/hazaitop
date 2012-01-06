# -*- encoding : utf-8 -*-
class HoboMigration7 < ActiveRecord::Migration
  def self.up
    create_table :activity_assocs do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :sectors do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :activities do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :organizations, :founded_at, :date
    add_column :organizations, :sector_id, :integer

    remove_column :litigation_relations, :name

    add_index :organizations, [:sector_id]
  end

  def self.down
    remove_column :organizations, :founded_at
    remove_column :organizations, :sector_id

    add_column :litigation_relations, :name, :string

    drop_table :activity_assocs
    drop_table :sectors
    drop_table :activities

    remove_index :organizations, :name => :index_organizations_on_sector_id rescue ActiveRecord::StatementInvalid
  end
end

