class HoboMigration5 < ActiveRecord::Migration
  def self.up
    rename_column :interorg_relations, :organization_a_id, :organization_id
    rename_column :interorg_relations, :organization_b_id, :related_organization_id

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid
    add_index :interorg_relations, [:organization_id]
    add_index :interorg_relations, [:related_organization_id]
  end

  def self.down
    rename_column :interorg_relations, :organization_id, :organization_a_id
    rename_column :interorg_relations, :related_organization_id, :organization_b_id

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_related_organization_id rescue ActiveRecord::StatementInvalid
    add_index :interorg_relations, [:organization_a_id]
    add_index :interorg_relations, [:organization_b_id]
  end
end
