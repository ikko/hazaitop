class HoboMigration34 < ActiveRecord::Migration
  def self.up
    change_column :notifications, :contracted_value, :string, :limit => 255
  end

  def self.down
    change_column :notifications, :contracted_value, :integer
  end
end
