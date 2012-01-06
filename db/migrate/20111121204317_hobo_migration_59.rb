# -*- encoding : utf-8 -*-
class HoboMigration59 < ActiveRecord::Migration
  def self.up
    add_column :contracts, :original_sum_value, :string
    add_column :contracts, :original_contracted_value, :string
    add_column :contracts, :tender_number, :string
    add_column :contracts, :tender_date, :date
  end

  def self.down
    remove_column :contracts, :original_sum_value
    remove_column :contracts, :original_contracted_value
    remove_column :contracts, :tender_number
    remove_column :contracts, :tender_date
  end
end

