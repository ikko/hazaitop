# -*- encoding : utf-8 -*-
class HoboMigration16 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :klink, :string

    add_column :people, :klink, :string
  end

  def self.down
    remove_column :organizations, :klink

    remove_column :people, :klink
  end
end

