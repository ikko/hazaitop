class HoboMigration89 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :description, :string
    add_column :organizations, :country_id_nr, :string
    add_column :organizations, :county_id_nr, :string

    remove_column :relations, :name
  end

  def self.down
    remove_column :organizations, :description
    remove_column :organizations, :country_id_nr
    remove_column :organizations, :county_id_nr

    add_column :relations, :name, :string
  end
end
