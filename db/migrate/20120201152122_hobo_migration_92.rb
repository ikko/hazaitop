class HoboMigration92 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :address, :string
  end

  def self.down
    remove_column :interorg_relations, :address
  end
end
