# -*- encoding : utf-8 -*-
class HoboMigration42 < ActiveRecord::Migration
  def self.up
    add_column :tenders, :unique_string, :text
  end

  def self.down
    remove_column :tenders, :unique_string
  end
end

