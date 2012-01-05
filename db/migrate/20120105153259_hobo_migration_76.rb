class HoboMigration76 < ActiveRecord::Migration
  def self.up
    add_column :articles, :name, :text
  end

  def self.down
    remove_column :articles, :name
  end
end
