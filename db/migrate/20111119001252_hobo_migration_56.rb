# -*- encoding : utf-8 -*-
class HoboMigration56 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :case_number, :string
  end

  def self.down
    remove_column :interorg_relations, :case_number
  end
end

