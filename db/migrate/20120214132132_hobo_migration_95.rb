class HoboMigration95 < ActiveRecord::Migration
  def self.up
    create_table :detailed_search_cpvs do |t|
      t.integer :cpv_id
      t.integer :detailed_search_id
    end
    add_index :detailed_search_cpvs, [:cpv_id]
    add_index :detailed_search_cpvs, [:detailed_search_id]

    add_column :cpvs, :description, :string
  end

  def self.down
    remove_column :cpvs, :description

    drop_table :detailed_search_cpvs
  end
end
