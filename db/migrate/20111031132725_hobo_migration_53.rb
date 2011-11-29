class HoboMigration53 < ActiveRecord::Migration
  def self.up
    add_column :o2o_relation_types, :label, :string

    add_column :p2o_relation_types, :label, :string

    add_column :p2p_relation_types, :label, :string

    add_column :o2p_relation_types, :label, :string
  end

  def self.down
    remove_column :o2o_relation_types, :label

    remove_column :p2o_relation_types, :label

    remove_column :p2p_relation_types, :label

    remove_column :o2p_relation_types, :label
  end
end
