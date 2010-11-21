class HoboMigration13 < ActiveRecord::Migration
  def self.up
    remove_column :interpersonal_relations, :name

    remove_column :person_to_org_relations, :name

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :interpersonal_relations, :name, :string

    add_column :person_to_org_relations, :name, :string

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'
  end
end
