class HoboMigration4 < ActiveRecord::Migration
  def self.up
    add_column :o2o_relation_types, :weight, :string

    add_column :p2o_relation_types, :weight, :string

    add_column :p2p_relation_types, :weight, :string
  end

  def self.down
    remove_column :o2o_relation_types, :weight

    remove_column :p2o_relation_types, :weight

    remove_column :p2p_relation_types, :weight
  end
end
