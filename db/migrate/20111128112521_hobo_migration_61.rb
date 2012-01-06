# -*- encoding : utf-8 -*-
class HoboMigration61 < ActiveRecord::Migration
  def self.up
    add_column :articles, :issued_at, :date
  end

  def self.down
    remove_column :articles, :issued_at
  end
end

