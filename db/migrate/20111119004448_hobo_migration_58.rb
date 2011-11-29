class HoboMigration58 < ActiveRecord::Migration
  def self.up
    remove_column :interorg_relations, :case_number
  end

  def self.down
    add_column :interorg_relations, :case_number, :string
  end
end
