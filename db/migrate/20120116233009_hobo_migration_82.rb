class HoboMigration82 < ActiveRecord::Migration
  def self.up
    add_column :detailed_searches, :amount_from, :integer
    add_column :detailed_searches, :amount_to, :integer
  end

  def self.down
    remove_column :detailed_searches, :amount_from
    remove_column :detailed_searches, :amount_to
  end
end
