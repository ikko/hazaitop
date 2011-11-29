class HoboMigration54 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :happened_at, :date

    add_column :contracts, :issued_at, :date
  end

  def self.down
    remove_column :interorg_relations, :happened_at

    remove_column :contracts, :issued_at
  end
end
