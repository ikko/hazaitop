class HoboMigration86 < ActiveRecord::Migration
  def self.up
    create_table :p2o_relations do |t|
      t.integer :relation_id
      t.integer :p2o_relation_type_id
    end
    add_index :p2o_relations, [:relation_id]
    add_index :p2o_relations, [:p2o_relation_type_id]

    create_table :o2o_relations do |t|
      t.integer :relation_id
      t.integer :o2o_relation_type_id
    end
    add_index :o2o_relations, [:relation_id]
    add_index :o2o_relations, [:o2o_relation_type_id]

    create_table :p2p_relations do |t|
      t.integer :relation_id
      t.integer :p2p_relation_type_id
    end
    add_index :p2p_relations, [:relation_id]
    add_index :p2p_relations, [:p2p_relation_type_id]
  end

  def self.down
    drop_table :p2o_relations
    drop_table :o2o_relations
    drop_table :p2p_relations
  end
end
