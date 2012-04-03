class HoboMigration102 < ActiveRecord::Migration
  def self.up
    rename_table :o2o_relations, :o_to_o_relations
    rename_table :p2p_relation_types, :p_to_p_relation_types
    rename_table :p2p_relations, :p_to_p_relations
    rename_table :p2o_relations, :p_to_o_relations
    rename_table :p2o_relation_types, :p_to_o_relation_types
    rename_table :o2o_relation_types, :o_to_o_relation_types
    rename_table :o2p_relation_types, :o_to_p_relation_types

    rename_column :p_to_o_relations, :p2o_relation_type_id, :p_to_o_relation_type_id

    rename_column :interorg_relations, :o2o_relation_type_id, :o_to_o_relation_type_id

    rename_column :interpersonal_relations, :p2p_relation_type_id, :p_to_p_relation_type_id

    rename_column :p_to_o_relation_types, :p2p_relation_type_id, :p_to_p_relation_type_id

    rename_column :person_to_org_relations, :o2p_relation_type_id, :o_to_p_relation_type_id
    rename_column :person_to_org_relations, :p2o_relation_type_id, :p_to_o_relation_type_id

    rename_column :o_to_p_relation_types, :p2p_relation_type_id, :p_to_p_relation_type_id

    rename_column :p_to_p_relations, :p2p_relation_type_id, :p_to_p_relation_type_id

    rename_column :o_to_o_relations, :o2o_relation_type_id, :o_to_o_relation_type_id

    rename_column :interpersonal_relation_calculators, :p2o_relation_type_id, :p_to_o_relation_type_id
    rename_column :interpersonal_relation_calculators, :related_p2o_relation_type_id, :related_p_to_o_relation_type_id
    rename_column :interpersonal_relation_calculators, :p2p_relation_type_id, :p_to_p_relation_type_id

    remove_index :p_to_o_relations, :name => :index_p2o_relations_on_relation_id rescue ActiveRecord::StatementInvalid
    remove_index :p_to_o_relations, :name => :index_p2o_relations_on_p2o_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :p_to_o_relations, [:relation_id]
    add_index :p_to_o_relations, [:p_to_o_relation_type_id]

    remove_index :interorg_relations, :name => :index_interorg_relations_on_o2o_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :interorg_relations, [:o_to_o_relation_type_id]

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :interpersonal_relations, [:p_to_p_relation_type_id]

    remove_index :p_to_p_relation_types, :name => :index_p2p_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
    remove_index :p_to_p_relation_types, :name => :index_p2p_relation_types_on_name rescue ActiveRecord::StatementInvalid
    add_index :p_to_p_relation_types, [:name]
    add_index :p_to_p_relation_types, [:pair_id]

    remove_index :o_to_o_relation_types, :name => :index_o2o_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
    add_index :o_to_o_relation_types, [:pair_id]

    remove_index :p_to_o_relation_types, :name => :index_p2o_relation_types_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :p_to_o_relation_types, :name => :index_p2o_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
    add_index :p_to_o_relation_types, [:p_to_p_relation_type_id]
    add_index :p_to_o_relation_types, [:pair_id]

    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_p2o_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_o2p_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :person_to_org_relations, [:p_to_o_relation_type_id]
    add_index :person_to_org_relations, [:o_to_p_relation_type_id]

    remove_index :o_to_p_relation_types, :name => :index_o2p_relation_types_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :o_to_p_relation_types, :name => :index_o2p_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
    remove_index :o_to_p_relation_types, :name => :index_o2p_relation_types_on_mirror_of_id rescue ActiveRecord::StatementInvalid
    add_index :o_to_p_relation_types, [:p_to_p_relation_type_id]
    add_index :o_to_p_relation_types, [:pair_id]
    add_index :o_to_p_relation_types, [:mirror_of_id]

    remove_index :p_to_p_relations, :name => :index_p2p_relations_on_relation_id rescue ActiveRecord::StatementInvalid
    remove_index :p_to_p_relations, :name => :index_p2p_relations_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :p_to_p_relations, [:relation_id]
    add_index :p_to_p_relations, [:p_to_p_relation_type_id]

    remove_index :o_to_o_relations, :name => :index_o2o_relations_on_relation_id rescue ActiveRecord::StatementInvalid
    remove_index :o_to_o_relations, :name => :index_o2o_relations_on_o2o_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :o_to_o_relations, [:relation_id]
    add_index :o_to_o_relations, [:o_to_o_relation_type_id]

    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_relation_calculators_on_p2p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_relation_calculators_on_p2o_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relation_calculators, :name => :matrix rescue ActiveRecord::StatementInvalid
    add_index :interpersonal_relation_calculators, [:p_to_p_relation_type_id]
    add_index :interpersonal_relation_calculators, [:p_to_o_relation_type_id]
    add_index :interpersonal_relation_calculators, [:related_p_to_o_relation_type_id], :name => 'matrix'
  end

  def self.down
    rename_column :p_to_o_relations, :p_to_o_relation_type_id, :p2o_relation_type_id

    rename_column :interorg_relations, :o_to_o_relation_type_id, :o2o_relation_type_id

    rename_column :interpersonal_relations, :p_to_p_relation_type_id, :p2p_relation_type_id

    rename_column :p_to_o_relation_types, :p_to_p_relation_type_id, :p2p_relation_type_id

    rename_column :person_to_org_relations, :o_to_p_relation_type_id, :o2p_relation_type_id
    rename_column :person_to_org_relations, :p_to_o_relation_type_id, :p2o_relation_type_id

    rename_column :o_to_p_relation_types, :p_to_p_relation_type_id, :p2p_relation_type_id

    rename_column :p_to_p_relations, :p_to_p_relation_type_id, :p2p_relation_type_id

    rename_column :o_to_o_relations, :o_to_o_relation_type_id, :o2o_relation_type_id

    rename_column :interpersonal_relation_calculators, :p_to_o_relation_type_id, :p2o_relation_type_id
    rename_column :interpersonal_relation_calculators, :related_p_to_o_relation_type_id, :related_p2o_relation_type_id
    rename_column :interpersonal_relation_calculators, :p_to_p_relation_type_id, :p2p_relation_type_id

    rename_table :o_to_o_relations, :o2o_relations
    rename_table :p_to_p_relation_types, :p2p_relation_types
    rename_table :p_to_p_relations, :p2p_relations
    rename_table :p_to_o_relations, :p2o_relations
    rename_table :p_to_o_relation_types, :p2o_relation_types
    rename_table :o_to_o_relation_types, :o2o_relation_types
    rename_table :o_to_p_relation_types, :o2p_relation_types

    remove_index :p2o_relations, :name => :index_p_to_o_relations_on_relation_id rescue ActiveRecord::StatementInvalid
    remove_index :p2o_relations, :name => :index_p_to_o_relations_on_p_to_o_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :p2o_relations, [:relation_id]
    add_index :p2o_relations, [:p2o_relation_type_id]

    remove_index :interorg_relations, :name => :index_interorg_relations_on_o_to_o_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :interorg_relations, [:o2o_relation_type_id]

    remove_index :interpersonal_relations, :name => :index_interpersonal_relations_on_p_to_p_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :interpersonal_relations, [:p2p_relation_type_id]

    remove_index :p2p_relation_types, :name => :index_p_to_p_relation_types_on_name rescue ActiveRecord::StatementInvalid
    remove_index :p2p_relation_types, :name => :index_p_to_p_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
    add_index :p2p_relation_types, [:pair_id]
    add_index :p2p_relation_types, [:name]

    remove_index :o2o_relation_types, :name => :index_o_to_o_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
    add_index :o2o_relation_types, [:pair_id]

    remove_index :p2o_relation_types, :name => :index_p_to_o_relation_types_on_p_to_p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :p2o_relation_types, :name => :index_p_to_o_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
    add_index :p2o_relation_types, [:p2p_relation_type_id]
    add_index :p2o_relation_types, [:pair_id]

    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_p_to_o_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :person_to_org_relations, :name => :index_person_to_org_relations_on_o_to_p_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :person_to_org_relations, [:p2o_relation_type_id]
    add_index :person_to_org_relations, [:o2p_relation_type_id]

    remove_index :o2p_relation_types, :name => :index_o_to_p_relation_types_on_p_to_p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :o2p_relation_types, :name => :index_o_to_p_relation_types_on_pair_id rescue ActiveRecord::StatementInvalid
    remove_index :o2p_relation_types, :name => :index_o_to_p_relation_types_on_mirror_of_id rescue ActiveRecord::StatementInvalid
    add_index :o2p_relation_types, [:p2p_relation_type_id]
    add_index :o2p_relation_types, [:pair_id]
    add_index :o2p_relation_types, [:mirror_of_id]

    remove_index :p2p_relations, :name => :index_p_to_p_relations_on_relation_id rescue ActiveRecord::StatementInvalid
    remove_index :p2p_relations, :name => :index_p_to_p_relations_on_p_to_p_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :p2p_relations, [:relation_id]
    add_index :p2p_relations, [:p2p_relation_type_id]

    remove_index :o2o_relations, :name => :index_o_to_o_relations_on_relation_id rescue ActiveRecord::StatementInvalid
    remove_index :o2o_relations, :name => :index_o_to_o_relations_on_o_to_o_relation_type_id rescue ActiveRecord::StatementInvalid
    add_index :o2o_relations, [:relation_id]
    add_index :o2o_relations, [:o2o_relation_type_id]

    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_relation_calculators_on_p_to_p_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relation_calculators, :name => :index_interpersonal_relation_calculators_on_p_to_o_relation_type_id rescue ActiveRecord::StatementInvalid
    remove_index :interpersonal_relation_calculators, :name => :matrix rescue ActiveRecord::StatementInvalid
    add_index :interpersonal_relation_calculators, [:p2p_relation_type_id]
    add_index :interpersonal_relation_calculators, [:p2o_relation_type_id]
    add_index :interpersonal_relation_calculators, [:related_p2o_relation_type_id], :name => 'matrix'
  end
end
