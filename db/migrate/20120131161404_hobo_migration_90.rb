class HoboMigration90 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :address, :string

    add_column :people, :address, :string

    add_column :detailed_searches, :address, :string
  end

  def self.down
    remove_column :organizations, :address

    remove_column :people, :address

    remove_column :detailed_searches, :address
  end
end
