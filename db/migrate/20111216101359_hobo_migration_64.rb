class HoboMigration64 < ActiveRecord::Migration
  def self.up
    add_column :o2o_relation_types, :parsed, :boolean, :default => false

    remove_column :p2o_relation_types, :role

    add_column :person_to_org_relations, :role, :string

    remove_column :o2p_relation_types, :role
  end

  def self.down
    remove_column :o2o_relation_types, :parsed

    add_column :p2o_relation_types, :role, :string

    remove_column :person_to_org_relations, :role

    add_column :o2p_relation_types, :role, :string
  end
end
