class HoboMigration11 < ActiveRecord::Migration
  def self.up
    add_column :o2o_relation_types, :pair_id, :integer

    add_index :o2o_relation_types, [:pair_id]

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :o2o_relation_types, :pair_id

    remove_index :o2o_relation_types, :name => :index_o2o_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'
  end
end
