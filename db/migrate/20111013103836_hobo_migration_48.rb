class HoboMigration48 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :financials_count, :integer, :default => 0
    change_column :organizations, :interorg_relations_count, :integer, :limit => 4, :default => 0
    change_column :organizations, :person_to_org_relations_count, :integer, :limit => 4, :default => 0
  end

  def self.down
    remove_column :organizations, :financials_count
    change_column :organizations, :interorg_relations_count, :integer
    change_column :organizations, :person_to_org_relations_count, :integer
  end
end
