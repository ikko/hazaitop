class HoboMigration100 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :no_start_time, :boolean, :default => false

    add_column :person_to_org_relations, :no_start_time, :boolean, :default => false
  end

  def self.down
    remove_column :interpersonal_relations, :no_start_time

    remove_column :person_to_org_relations, :no_start_time
  end
end
