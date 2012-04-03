class HoboMigration101 < ActiveRecord::Migration
  def self.up
    add_index :p2p_relation_types, [:name]
  end

  def self.down
    remove_index :p2p_relation_types, :name => :index_p2p_relation_types_on_name rescue ActiveRecord::StatementInvalid
  end
end
