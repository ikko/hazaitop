class HoboMigration79 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :company, :boolean, :default => false
  end

  def self.down
    remove_column :organizations, :company
  end
end
