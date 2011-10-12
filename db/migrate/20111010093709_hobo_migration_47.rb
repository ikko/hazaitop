class HoboMigration47 < ActiveRecord::Migration
  def self.up
    create_table :fronts do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    change_column :financials, :balance_sheet_total, :integer, :limit => 8
  end

  def self.down
    change_column :financials, :balance_sheet_total, :integer

    drop_table :fronts
  end
end
