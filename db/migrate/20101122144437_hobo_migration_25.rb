class HoboMigration25 < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid

    add_index :interpersonal_relation_calculators, [:related_p2o_relation_type_id]
  end

  def self.down
    drop_table :settings

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'

    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_relation_calculators_on_related_p2o_relation_type_id rescue ActiveRecord::StatementInvalid
  end
end
