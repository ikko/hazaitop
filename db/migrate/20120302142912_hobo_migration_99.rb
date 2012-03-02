class HoboMigration99 < ActiveRecord::Migration
  def self.up
    add_column :people, :order_name, :string
  end

  def self.down
    remove_column :people, :order_name
  end
end
