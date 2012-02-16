class HoboMigration98 < ActiveRecord::Migration
  def self.up
    add_column :articles, :original_internet_address, :string
    add_column :articles, :original_source, :string
  end

  def self.down
    remove_column :articles, :original_internet_address
    remove_column :articles, :original_source
  end
end
