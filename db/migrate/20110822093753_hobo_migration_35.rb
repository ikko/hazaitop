class HoboMigration35 < ActiveRecord::Migration
  def self.up
    change_column :notifications, :contracted_value, :integer, :limit => 8
  end

  def self.down
    change_column :notifications, :contracted_value, :string
  end
end
