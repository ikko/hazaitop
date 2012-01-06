# -*- encoding : utf-8 -*-
class HoboMigration24 < ActiveRecord::Migration
  def self.up
    change_column :o2o_relation_types, :weight, :float, :default => 1

    add_column :interpersonal_relations, :mirror, :boolean, :default => false

    add_column :interorg_relations, :mirror, :boolean, :default => false

    change_column :p2o_relation_types, :weight, :float, :default => 1

    change_column :p2p_relation_types, :weight, :float, :default => 1

    change_column :o2p_relation_types, :weight, :float, :default => 1
  end

  def self.down
    change_column :o2o_relation_types, :weight, :float

    remove_column :interpersonal_relations, :mirror

    remove_column :interorg_relations, :mirror

    change_column :p2o_relation_types, :weight, :float

    change_column :p2p_relation_types, :weight, :float

    change_column :o2p_relation_types, :weight, :float
  end
end

