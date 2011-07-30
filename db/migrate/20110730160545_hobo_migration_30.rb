class HoboMigration30 < ActiveRecord::Migration
  def self.up
    rename_column :contracts, :no_of_other_proposals, :no_of_proposals

    remove_column :notifications, :site_id
  end

  def self.down
    rename_column :contracts, :no_of_proposals, :no_of_other_proposals

    add_column :notifications, :site_id, :integer
  end
end
