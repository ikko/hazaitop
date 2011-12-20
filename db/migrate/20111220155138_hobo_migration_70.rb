class HoboMigration70 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :parsed, :boolean, :default => false
  end

  def self.down
    remove_column :interpersonal_relations, :parsed
  end
end
