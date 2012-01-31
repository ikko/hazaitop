class HoboMigration88 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :relations_bit, :boolean, :default => false
    add_column :organizations, :civil, :boolean, :default => false

    add_column :people, :relations_bit, :boolean, :default => false
  end

  def self.down
    remove_column :organizations, :relations_bit
    remove_column :organizations, :civil

    remove_column :people, :relations_bit
  end
end
