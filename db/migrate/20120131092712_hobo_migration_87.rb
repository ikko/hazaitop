class HoboMigration87 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :relations_counter, :integer, :default => 0

    add_column :relations, :name, :string

    add_column :people, :relations_counter, :integer, :default => 0
  end

  def self.down
    remove_column :organizations, :relations_counter

    remove_column :relations, :name

    remove_column :people, :relations_counter
  end
end
