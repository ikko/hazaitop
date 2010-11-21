class HoboMigration12 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :mirrored, :boolean, :default => false
    add_column :interpersonal_relations, :person_id, :integer
    add_column :interpersonal_relations, :related_person_id, :integer
    add_column :interpersonal_relations, :interpersonal_relation_id, :integer
    remove_column :interpersonal_relations, :end_time
    remove_column :interpersonal_relations, :person_b_id
    remove_column :interpersonal_relations, :person_a_id
    remove_column :interpersonal_relations, :user_id
    remove_column :interpersonal_relations, :value
    remove_column :interpersonal_relations, :start_time

    remove_column :interorg_relations, :needs_sync
    remove_column :interorg_relations, :copied

    add_column :person_to_org_relations, :p2o_relation_type_id, :integer
    remove_column :person_to_org_relations, :p2p_relation_type_id
    remove_column :person_to_org_relations, :user_id
    remove_column :person_to_org_relations, :value

    add_column :p2p_relation_types, :pair_id, :integer

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_person_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_person_b_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_user_id rescue ActiveRecord::StatementInvalid
    add_index :interpersonal_relations, [:person_id]
    add_index :interpersonal_relations, [:related_person_id]
    add_index :interpersonal_relations, [:interpersonal_relation_id]

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid

    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_user_id rescue ActiveRecord::StatementInvalid
    add_index :person_to_org_relations, [:p2o_relation_type_id]

    add_index :p2p_relation_types, [:pair_id]
  end

  def self.down
    remove_column :interpersonal_relations, :mirrored
    remove_column :interpersonal_relations, :person_id
    remove_column :interpersonal_relations, :related_person_id
    remove_column :interpersonal_relations, :interpersonal_relation_id
    add_column :interpersonal_relations, :end_time, :date
    add_column :interpersonal_relations, :person_b_id, :integer
    add_column :interpersonal_relations, :person_a_id, :integer
    add_column :interpersonal_relations, :user_id, :integer
    add_column :interpersonal_relations, :value, :integer
    add_column :interpersonal_relations, :start_time, :date

    add_column :interorg_relations, :needs_sync, :boolean, :default => true
    add_column :interorg_relations, :copied, :boolean, :default => false

    remove_column :person_to_org_relations, :p2o_relation_type_id
    add_column :person_to_org_relations, :p2p_relation_type_id, :integer
    add_column :person_to_org_relations, :user_id, :integer
    add_column :person_to_org_relations, :value, :integer

    remove_column :p2p_relation_types, :pair_id

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_person_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_related_person_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_interpersonal_relation_id rescue ActiveRecord::StatementInvalid
    add_index :interpersonal_relations, [:person_a_id]
    add_index :interpersonal_relations, [:person_b_id]
    add_index :interpersonal_relations, [:user_id]

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'

    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_p2o_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :person_to_org_relations, [:p2p_relation_type_id]
    add_index :person_to_org_relations, [:user_id]

    remove_index :p2p_relation_types, :name => :index_p2p_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
  end
end
