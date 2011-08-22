class HoboMigration37 < ActiveRecord::Migration
  def self.up
    change_column :interorg_relations, :value, :integer, :limit => 8

    change_column :contracts, :sum_value, :integer, :limit => 8
    change_column :contracts, :estimated_value, :integer, :limit => 8
    change_column :contracts, :contracted_value, :integer, :limit => 8

    change_column :notifications, :contracted_value, :integer, :limit => 8
  end

  def self.down
    change_column :interorg_relations, :value, :integer, :limit => 18, :precision => 18, :scale => 0

    change_column :contracts, :sum_value, :integer
    change_column :contracts, :estimated_value, :integer
    change_column :contracts, :contracted_value, :integer

    change_column :notifications, :contracted_value, :integer
  end
end
