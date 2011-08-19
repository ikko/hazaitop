class HoboMigration33 < ActiveRecord::Migration
  def self.up
    add_column :notifications, :contracted_value, :integer
  end

  def self.down
    remove_column :notifications, :contracted_value
  end
end
