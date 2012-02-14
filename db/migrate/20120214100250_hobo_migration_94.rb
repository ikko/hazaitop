class HoboMigration94 < ActiveRecord::Migration
  def self.up
    rename_column :detailed_searches, :transaction, :contract
    add_column :detailed_searches, :tender, :boolean
  end

  def self.down
    rename_column :detailed_searches, :contract, :transaction
    remove_column :detailed_searches, :tender
  end
end
