class HoboMigration67 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :ksh_number_from, :date
    add_column :organizations, :social_security_number_from, :date
    add_column :organizations, :stock, :integer, :limit => 8
    remove_column :organizations, :law_successed_at
    remove_column :organizations, :law_successor_cgjsz
  end

  def self.down
    remove_column :organizations, :ksh_number_from
    remove_column :organizations, :social_security_number_from
    remove_column :organizations, :stock
    add_column :organizations, :law_successed_at, :date
    add_column :organizations, :law_successor_cgjsz, :string
  end
end
