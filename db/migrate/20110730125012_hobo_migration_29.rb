class HoboMigration29 < ActiveRecord::Migration
  def self.up
    add_column :contracts, :s_vat_incl, :boolean
    add_column :contracts, :c_vat_incl, :boolean
    add_column :contracts, :e_vat_incl, :boolean
    remove_column :contracts, :contracting_at
    remove_column :contracts, :vat_incl
  end

  def self.down
    remove_column :contracts, :s_vat_incl
    remove_column :contracts, :c_vat_incl
    remove_column :contracts, :e_vat_incl
    add_column :contracts, :contracting_at, :date
    add_column :contracts, :vat_incl, :boolean
  end
end
