# -*- encoding : utf-8 -*-
class HoboMigration72 < ActiveRecord::Migration
  def self.up
    add_column :o2p_relation_types, :mirror_of_id, :integer

    add_index :o2p_relation_types, [:mirror_of_id]
  end

  def self.down
    remove_column :o2p_relation_types, :mirror_of_id

    remove_index :o2p_relation_types, :name => :index_o2p_relation_types_on_mirror_of_id rescue ActiveRecord::StatementInvalid
  end
end

