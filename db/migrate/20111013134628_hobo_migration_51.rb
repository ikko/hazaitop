# -*- encoding : utf-8 -*-
class HoboMigration51 < ActiveRecord::Migration
  def self.up
    change_column :people, :interpersonal_relations_count, :integer, :limit => 4, :default => 0
    change_column :people, :person_to_org_relations_count, :integer, :limit => 4, :default => 0
  end

  def self.down
    change_column :people, :interpersonal_relations_count, :integer
    change_column :people, :person_to_org_relations_count, :integer
  end
end

