class HoboMigration16 < ActiveRecord::Migration
  def self.up
    change_column :person_to_org_relations, :end_time, :date
    change_column :person_to_org_relations, :start_time, :date

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid

  end

  def self.down
    change_column :person_to_org_relations, :end_time, :datetime
    change_column :person_to_org_relations, :start_time, :datetime

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'

  end
end
