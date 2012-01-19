class HoboMigration83 < ActiveRecord::Migration
  def self.up
    create_table :relations do |t|
    end
  end

  def self.down
    drop_table :relations
  end
end
