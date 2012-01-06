# -*- encoding : utf-8 -*-
class HoboMigration36 < ActiveRecord::Migration
  def self.up
    change_column :financials, :turnover, :integer, :limit => 8

    change_column :interorg_relations, :value, :decimal, :limit => nil, :precision => 18, :scale => 0

    change_column :notifications, :contracted_value, :integer, :limit => 4
  end

  def self.down
    change_column :financials, :turnover, :integer

    change_column :interorg_relations, :value, :integer

    change_column :notifications, :contracted_value, :integer, :limit => 8
  end
end

