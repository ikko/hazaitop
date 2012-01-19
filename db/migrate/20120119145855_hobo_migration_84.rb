class HoboMigration84 < ActiveRecord::Migration
  def self.up
    add_column :relations, :detailed_search_id, :integer

    add_index :relations, [:detailed_search_id]
  end

  def self.down
    remove_column :relations, :detailed_search_id

    remove_index :relations, :name => :index_relations_on_detailed_search_id rescue ActiveRecord::StatementInvalid
  end
end
