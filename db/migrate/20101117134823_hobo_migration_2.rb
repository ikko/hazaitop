class HoboMigration2 < ActiveRecord::Migration
  def self.up
    create_table :interpersonal_relations do |t|
      t.string   :name
      t.date     :start_time
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :p2p_relation_type_id
      t.integer  :person_a_id
      t.integer  :person_b_id
      t.integer  :information_source_id
      t.integer  :user_id
    end
    add_index :interpersonal_relations, [:p2p_relation_type_id]
    add_index :interpersonal_relations, [:person_a_id]
    add_index :interpersonal_relations, [:person_b_id]
    add_index :interpersonal_relations, [:information_source_id]
    add_index :interpersonal_relations, [:user_id]

    create_table :organizations do |t|
      t.string   :name
      t.string   :street1
      t.string   :street2
      t.string   :zip_code
      t.string   :trade_register_nr
      t.string   :tax_nr
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :information_source_id
      t.integer  :user_id
    end
    add_index :organizations, [:information_source_id]
    add_index :organizations, [:user_id]

    create_table :o2o_relation_types do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :interorg_relations do |t|
      t.string   :name
      t.date     :start_time
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :o2o_relation_type_id
      t.integer  :organization_a_id
      t.integer  :organization_b_id
      t.integer  :information_source_id
      t.integer  :user_id
    end
    add_index :interorg_relations, [:o2o_relation_type_id]
    add_index :interorg_relations, [:organization_a_id]
    add_index :interorg_relations, [:organization_b_id]
    add_index :interorg_relations, [:information_source_id]
    add_index :interorg_relations, [:user_id]

    create_table :p2o_relation_types do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :person_to_org_relations do |t|
      t.string   :name
      t.date     :start_time
      t.date     :end_time
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :p2p_relation_type_id
      t.integer  :person_id
      t.integer  :organization_id
      t.integer  :information_source_id
      t.integer  :user_id
    end
    add_index :person_to_org_relations, [:p2p_relation_type_id]
    add_index :person_to_org_relations, [:person_id]
    add_index :person_to_org_relations, [:organization_id]
    add_index :person_to_org_relations, [:information_source_id]
    add_index :person_to_org_relations, [:user_id]

    create_table :information_sources do |t|
      t.string   :name
      t.string   :web
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :p2p_relation_types do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :people do |t|
      t.string   :first_name
      t.string   :last_name
      t.date     :born_at
      t.string   :mothers_name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :information_source_id
      t.integer  :user_id
    end
    add_index :people, [:information_source_id]
    add_index :people, [:user_id]
  end

  def self.down
    drop_table :interpersonal_relations
    drop_table :organizations
    drop_table :o2o_relation_types
    drop_table :interorg_relations
    drop_table :p2o_relation_types
    drop_table :person_to_org_relations
    drop_table :information_sources
    drop_table :p2p_relation_types
    drop_table :people
  end
end
