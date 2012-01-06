# -*- encoding : utf-8 -*-
class HoboMigration69 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :parsed, :boolean, :default => false

    add_column :person_to_org_relations, :parsed, :boolean, :default => false
  end

  def self.down
    remove_column :interorg_relations, :parsed

    remove_column :person_to_org_relations, :parsed
  end
end

