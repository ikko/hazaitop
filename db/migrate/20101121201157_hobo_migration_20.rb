class HoboMigration20 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :other_person_to_org_relation_id, :integer

    add_index :interpersonal_relations, [:other_person_to_org_relation_id]

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid

  end

  def self.down
    remove_column :interpersonal_relations, :other_person_to_org_relation_id

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_other_person_to_org_relation_id rescue ActiveRecord::StatementInvalid

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'

  end
end
