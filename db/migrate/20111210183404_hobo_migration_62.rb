# -*- encoding : utf-8 -*-
class HoboMigration62 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :country, :string

    add_column :people, :street, :string
    add_column :people, :city, :string
    add_column :people, :zip_code, :string
    add_column :people, :country, :string
  end

  def self.down
    remove_column :organizations, :country

    remove_column :people, :street
    remove_column :people, :city
    remove_column :people, :zip_code
    remove_column :people, :country
  end
end

