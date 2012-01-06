# -*- encoding : utf-8 -*-
class HoboMigration25 < ActiveRecord::Migration
  def self.up
    create_table :person_saves do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :person_id
    end
    add_index :person_saves, [:user_id]
    add_index :person_saves, [:person_id]

    create_table :org_saves do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :organization_id
    end
    add_index :org_saves, [:user_id]
    add_index :org_saves, [:organization_id]

    add_index :interpersonal_relations, [:p2p_relation_type_id]
    add_index :interpersonal_relations, [:person_to_org_relation_id]
    add_index :interpersonal_relations, [:other_person_to_org_relation_id]
    add_index :interpersonal_relations, [:information_source_id]
    add_index :interpersonal_relations, [:interpersonal_relation_id]

    add_index :person_to_org_relations, [:p2o_relation_type_id]
    add_index :person_to_org_relations, [:o2p_relation_type_id]
    add_index :person_to_org_relations, [:information_source_id]

    add_index :litigation_relations, [:litigable_type, :litigable_id]

    add_index :interpersonal_relation_calculators, [:p2p_relation_type_id]
    add_index :interpersonal_relation_calculators, [:p2o_relation_type_id]
  end

  def self.down
    drop_table :person_saves
    drop_table :org_saves

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_person_to_org_relation_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_other_person_to_org_relation_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_information_source_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_interpersonal_relation_id rescue ActiveRecord::StatementInvalid

    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_p2o_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_o2p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_information_source_id rescue ActiveRecord::StatementInvalid

    remove_index :litigation_relations, :name => :index_litigation_relations_on_litigable_type_and_litigable_id rescue ActiveRecord::StatementInvalid

    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_relation_calculators_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_relation_calculators_on_p2o_relation_type_id rescue ActiveRecord::StatementInvalid
  end
end

