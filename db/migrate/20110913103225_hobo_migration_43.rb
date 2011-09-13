class HoboMigration43 < ActiveRecord::Migration
  def self.up
    change_column :tenders, :subsidy, :float, :limit => nil
  end

  def self.down
    change_column :tenders, :subsidy, :integer
  end
end
