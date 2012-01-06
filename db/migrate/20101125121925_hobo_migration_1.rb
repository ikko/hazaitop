# -*- encoding : utf-8 -*-

class HoboMigration1 < ActiveRecord::Migration
  def self.up
    create_table :interpersonal_relations do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean  :mirrored, :default => false
      t.boolean  :internal, :default => false
      t.float    :weight
      t.integer  :p2p_relation_type_id
      t.integer  :person_id
      t.integer  :related_person_id
      t.integer  :person_to_org_relation_id
      t.integer  :other_person_to_org_relation_id
      t.integer  :organization_id
      t.integer  :information_source_id
      t.integer  :interpersonal_relation_id
    end
    add_index :interpersonal_relations, [:p2p_relation_type_id]
    add_index :interpersonal_relations, [:person_id]
    add_index :interpersonal_relations, [:related_person_id]
    add_index :interpersonal_relations, [:person_to_org_relation_id]
    add_index :interpersonal_relations, [:other_person_to_org_relation_id]
    add_index :interpersonal_relations, [:organization_id]
    add_index :interpersonal_relations, [:information_source_id]
    add_index :interpersonal_relations, [:interpersonal_relation_id]

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
      t.float    :weight
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :pair_id
    end
    add_index :o2o_relation_types, [:pair_id]

    create_table :interorg_relations do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean  :mirrored, :default => false
      t.float    :weight
      t.integer  :o2o_relation_type_id
      t.integer  :organization_id
      t.integer  :related_organization_id
      t.integer  :information_source_id
      t.integer  :interorg_relation_id
    end
    add_index :interorg_relations, [:o2o_relation_type_id]
    add_index :interorg_relations, [:organization_id]
    add_index :interorg_relations, [:related_organization_id]
    add_index :interorg_relations, [:information_source_id]
    add_index :interorg_relations, [:interorg_relation_id]

    create_table :affairs do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :p2o_relation_types do |t|
      t.string   :name
      t.integer  :weight
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :p2p_relation_type_id
      t.integer  :pair_id
    end
    add_index :p2o_relation_types, [:p2p_relation_type_id]
    add_index :p2o_relation_types, [:pair_id]

    create_table :person_to_org_relations do |t|
      t.date     :start_time
      t.date     :end_time
      t.datetime :created_at
      t.datetime :updated_at
      t.float    :weight
      t.integer  :p2o_relation_type_id
      t.integer  :o2p_relation_type_id
      t.integer  :organization_id
      t.integer  :person_id
      t.integer  :information_source_id
    end
    add_index :person_to_org_relations, [:p2o_relation_type_id]
    add_index :person_to_org_relations, [:o2p_relation_type_id]
    add_index :person_to_org_relations, [:organization_id]
    add_index :person_to_org_relations, [:person_id]
    add_index :person_to_org_relations, [:information_source_id]

    create_table :information_sources do |t|
      t.string   :name
      t.string   :web
      t.float    :weight
      t.boolean  :internal, :default => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :litigation_relations do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :litigable_id
      t.string   :litigable_type
      t.integer  :litigation_id
    end
    add_index :litigation_relations, [:litigable_type, :litigable_id]
    add_index :litigation_relations, [:litigation_id]

    create_table :settings do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :p2p_relation_types do |t|
      t.string   :name
      t.float    :weight
      t.boolean  :internal, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :pair_id
    end
    add_index :p2p_relation_types, [:pair_id]

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
#    add_index :interpersonal_relation_calculators, [:related_p2o_relation_type_id]

    create_table :o2p_relation_types do |t|
      t.string   :name
      t.integer  :weight
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :p2p_relation_type_id
      t.integer  :pair_id
    end
    add_index :o2p_relation_types, [:p2p_relation_type_id]
    add_index :o2p_relation_types, [:pair_id]

    create_table :people do |t|
      t.string   :first_name
      t.string   :last_name
      t.string   :name
      t.date     :born_at
      t.string   :mothers_name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :place_of_birth_id
      t.integer  :information_source_id
      t.integer  :user_id
    end
    add_index :people, [:place_of_birth_id]
    add_index :people, [:information_source_id]
    add_index :people, [:user_id]

    create_table :place_of_births do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :litigations do |t|
      t.string   :name
      t.text     :description
      t.date     :start_time
      t.date     :end_time
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :users do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :name
      t.string   :email_address
      t.boolean  :administrator, :default => false
      t.boolean  :editor, :default => false
      t.boolean  :supervisor, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :state, :default => "invited"
      t.datetime :key_timestamp
    end
    add_index :users, [:state]

    create_table :articles do |t|
      t.string   :web
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :interpersonal_relations
    drop_table :organizations
    drop_table :o2o_relation_types
    drop_table :interorg_relations
    drop_table :affairs
    drop_table :p2o_relation_types
    drop_table :person_to_org_relations
    drop_table :information_sources
    drop_table :litigation_relations
    drop_table :settings
    drop_table :p2p_relation_types
    drop_table :interpersonal_relation_calculators
    drop_table :o2p_relation_types
    drop_table :people
    drop_table :place_of_births
    drop_table :litigations
    drop_table :users
    drop_table :articles
  end
end

