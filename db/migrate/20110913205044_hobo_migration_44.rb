# -*- encoding : utf-8 -*-
class HoboMigration44 < ActiveRecord::Migration
  def self.up
    add_column :tenders, :url, :string
  end

  def self.down
    remove_column :tenders, :url
  end
end

