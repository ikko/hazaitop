class HoboMigration91 < ActiveRecord::Migration
  def self.up
    add_column :contracts, :place_of_performance, :string
  end

  def self.down
    remove_column :contracts, :place_of_performance
  end
end
