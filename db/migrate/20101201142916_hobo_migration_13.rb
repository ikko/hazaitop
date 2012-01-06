# -*- encoding : utf-8 -*-
class HoboMigration13 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :visual, :boolean, :default => true

    add_column :o2o_relation_types, :visual, :boolean, :default => true

    add_column :interorg_relations, :visual, :boolean, :default => true

    add_column :p2o_relation_types, :visual, :boolean, :default => true

    add_column :person_to_org_relations, :visual, :boolean, :default => true

    add_column :p2p_relation_types, :visual, :boolean, :default => true

    add_column :o2p_relation_types, :visual, :boolean, :default => true
  end

  def self.down
    remove_column :interpersonal_relations, :visual

    remove_column :o2o_relation_types, :visual

    remove_column :interorg_relations, :visual

    remove_column :p2o_relation_types, :visual

    remove_column :person_to_org_relations, :visual

    remove_column :p2p_relation_types, :visual

    remove_column :o2p_relation_types, :visual
  end
end

