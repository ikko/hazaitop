# -*- encoding : utf-8 -*-
class HoboMigration57 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :issued_at, :date
    remove_column :interorg_relations, :happened_at

    add_column :contracts, :case_number, :string
  end

  def self.down
    remove_column :interorg_relations, :issued_at
    add_column :interorg_relations, :happened_at, :date

    remove_column :contracts, :case_number
  end
end

