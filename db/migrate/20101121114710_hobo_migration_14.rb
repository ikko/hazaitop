class HoboMigration14 < ActiveRecord::Migration
  def self.up
    create_table :revealed_interpersonal_relations do |t|
      t.integer  :weight
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :interpersonal_relation_calculators do |t|
      t.integer  :weight
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :p2p_relation_type_id
      t.integer  :p2o_relation_type_id
      t.integer  :related_p2o_relation_type_id
    end
    add_index :interpersonal_relation_calculators, [:p2p_relation_type_id]
    add_index :interpersonal_relation_calculators, [:p2o_relation_type_id]
    add_index :interpersonal_relation_calculators, [:related_p2o_relation_type_id]

    add_column :interpersonal_relations, :person_to_org_relation_id, :integer

    remove_column :organizations, :end_time
    remove_column :organizations, :start_time

    change_column :o2o_relation_types, :weight, :float, :limit => nil

    add_column :p2o_relation_types, :p2p_relation_type_id, :integer
    change_column :p2o_relation_types, :weight, :integer, :limit => 4

    add_column :information_sources, :internal, :boolean, :default => false
    change_column :information_sources, :weight, :float, :limit => nil

    change_column :p2p_relation_types, :weight, :float, :limit => nil

    add_index :interpersonal_relations, [:person_to_org_relation_id]

    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_a_id rescue ActiveRecord::StatementInvalid
    remove_index :interorg_relations, :name => :index_interorg_relations_on_organization_b_id rescue ActiveRecord::StatementInvalid

    add_index :p2o_relation_types, [:p2p_relation_type_id]
  end

  def self.down
    remove_column :interpersonal_relations, :person_to_org_relation_id

    add_column :organizations, :end_time, :date
    add_column :organizations, :start_time, :date

    change_column :o2o_relation_types, :weight, :string

    remove_column :p2o_relation_types, :p2p_relation_type_id
    change_column :p2o_relation_types, :weight, :string

    remove_column :information_sources, :internal
    change_column :information_sources, :weight, :integer

    change_column :p2p_relation_types, :weight, :string

    drop_table :revealed_interpersonal_relations
    drop_table :interpersonal_relation_calculators

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_person_to_org_relation_id rescue ActiveRecord::StatementInvalid

    add_index :interorg_relations, [:organization_id], :name => 'index_interorg_relations_on_organization_a_id'
    add_index :interorg_relations, [:related_organization_id], :name => 'index_interorg_relations_on_organization_b_id'

    remove_index :p2o_relation_types, :name => :index_p2o_relation_types_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
  end
end
