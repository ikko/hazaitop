class HoboMigration8 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :mirrored, :boolean, :default => false
    add_column :interorg_relations, :interorg_relation_id, :integer
    remove_column :interorg_relations, :end_time
    remove_column :interorg_relations, :user_id
    remove_column :interorg_relations, :value
    remove_column :interorg_relations, :start_time

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_user_id rescue ActiveRecord::StatementInvalid
    add_index :interorg_relations, [:interorg_relation_id]
  end

  def self.down
    remove_column :interorg_relations, :mirrored
    remove_column :interorg_relations, :interorg_relation_id
    add_column :interorg_relations, :end_time, :date
    add_column :interorg_relations, :user_id, :integer
    add_column :interorg_relations, :value, :integer
    add_column :interorg_relations, :start_time, :date

    remove_index :interorg_relations, :name => :index_interorg_relations_on_interorg_relation_id rescue ActiveRecord::StatementInvalid
    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'
    add_index :interorg_relations, [:user_id]
  end
end
