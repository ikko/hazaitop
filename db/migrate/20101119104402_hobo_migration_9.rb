class HoboMigration9 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :needs_sync, :boolean, :default => true

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :interorg_relations, :needs_sync

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'
  end
end
