class HoboMigration85 < ActiveRecord::Migration
  def self.up
    create_table :detailed_search_relations do |t|
      t.integer :relation_id
      t.integer :detailed_search_id
    end
    add_index :detailed_search_relations, [:relation_id]
    add_index :detailed_search_relations, [:detailed_search_id]

    remove_column :relations, :detailed_search_id

    remove_index :relations, :name => :index_relations_on_detailed_search_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :relations, :detailed_search_id, :integer

    drop_table :detailed_search_relations

    add_index :relations, [:detailed_search_id]
  end
end
