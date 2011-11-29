class HoboMigration55 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :name, :text
  end

  def self.down
    remove_column :interorg_relations, :name
  end
end
