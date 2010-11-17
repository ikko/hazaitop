class HoboMigration3 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :end_time, :date
    add_column :interpersonal_relations, :value, :integer

    add_column :organizations, :start_time, :date
    add_column :organizations, :end_time, :date

    add_column :interorg_relations, :end_time, :date
    add_column :interorg_relations, :value, :integer

    add_column :person_to_org_relations, :value, :integer

    add_column :information_sources, :weight, :integer
  end

  def self.down
    remove_column :interpersonal_relations, :end_time
    remove_column :interpersonal_relations, :value

    remove_column :organizations, :start_time
    remove_column :organizations, :end_time

    remove_column :interorg_relations, :end_time
    remove_column :interorg_relations, :value

    remove_column :person_to_org_relations, :value

    remove_column :information_sources, :weight
  end
end
