# -*- encoding : utf-8 -*-
class HoboMigration63 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :complexed_at, :date

    add_column :p2o_relation_types, :role, :string
    add_column :p2o_relation_types, :parsed, :boolean, :default => false

    add_column :p2p_relation_types, :parsed, :boolean, :default => false

    add_column :o2p_relation_types, :role, :string
    add_column :o2p_relation_types, :parsed, :boolean, :default => false

    add_column :people, :complexed_at, :date
  end

  def self.down
    remove_column :organizations, :complexed_at

    remove_column :p2o_relation_types, :role
    remove_column :p2o_relation_types, :parsed

    remove_column :p2p_relation_types, :parsed

    remove_column :o2p_relation_types, :role
    remove_column :o2p_relation_types, :parsed

    remove_column :people, :complexed_at
  end
end

