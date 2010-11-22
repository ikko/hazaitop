class HoboMigration18 < ActiveRecord::Migration
  def self.up
    add_column :person_to_org_relations, :duplex_hack, :boolean, :default => true

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid

  end

  def self.down
    remove_column :person_to_org_relations, :duplex_hack

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'

  end
end
