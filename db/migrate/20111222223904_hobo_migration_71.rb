# -*- encoding : utf-8 -*-
class HoboMigration71 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :complex_xml, :text

    add_column :people, :complex_xml, :text
  end

  def self.down
    remove_column :organizations, :complex_xml

    remove_column :people, :complex_xml
  end
end

