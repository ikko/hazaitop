class HoboMigration15 < ActiveRecord::Migration
  def self.up
    change_column :person_to_org_relations, :end_time, :datetime
    change_column :person_to_org_relations, :start_time, :datetime

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid

    add_index :interpersonal_relation_calculators, [:related_p2o_relation_type_id]
  end

  def self.down
    change_column :person_to_org_relations, :end_time, :date
    change_column :person_to_org_relations, :start_time, :date

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'

    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_relation_calculators_on_related_p2o_relation_type_id rescue ActiveRecord::StatementInvalid
  end
end
