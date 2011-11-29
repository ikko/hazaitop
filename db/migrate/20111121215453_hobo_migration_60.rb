class HoboMigration60 < ActiveRecord::Migration
  def self.up
    remove_column :contracts, :tender_date
    remove_column :contracts, :tender_number
  end

  def self.down
    add_column :contracts, :tender_date, :date
    add_column :contracts, :tender_number, :string
  end
end
