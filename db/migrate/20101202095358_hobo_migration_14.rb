class HoboMigration14 < ActiveRecord::Migration
  def self.up
    add_column :o2o_relation_types, :litig, :boolean, :default => false

    add_column :p2o_relation_types, :litig, :boolean, :default => false

    add_column :p2p_relation_types, :litig, :boolean, :default => false

    add_column :o2p_relation_types, :litig, :boolean, :default => false
  end

  def self.down
    remove_column :o2o_relation_types, :litig

    remove_column :p2o_relation_types, :litig

    remove_column :p2p_relation_types, :litig

    remove_column :o2p_relation_types, :litig
  end
end
