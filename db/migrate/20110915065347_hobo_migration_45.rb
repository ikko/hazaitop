# -*- encoding : utf-8 -*-
class HoboMigration45 < ActiveRecord::Migration
  def self.up
    add_column :tenders, :found, :string
    add_column :tenders, :source, :string
  end

  def self.down
    remove_column :tenders, :found
    remove_column :tenders, :source
  end
end

