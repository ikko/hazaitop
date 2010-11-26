class HoboMigration6 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :start_time, :date
    add_column :interpersonal_relations, :end_time, :date
  end

  def self.down
    remove_column :interpersonal_relations, :start_time
    remove_column :interpersonal_relations, :end_time
  end
end
