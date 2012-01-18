class HoboMigration80 < ActiveRecord::Migration
  def self.up
    create_table :detailed_search_place_of_births do |t|
      t.integer :place_of_birth_id
      t.integer :detailed_search_id
    end
    add_index :detailed_search_place_of_births, [:place_of_birth_id]
    add_index :detailed_search_place_of_births, [:detailed_search_id]

    create_table :detailed_search_sectors do |t|
      t.integer :sector_id
      t.integer :detailed_search_id
    end
    add_index :detailed_search_sectors, [:sector_id]
    add_index :detailed_search_sectors, [:detailed_search_id]

    create_table :detailed_search_activities do |t|
      t.integer :activity_id
      t.integer :detailed_search_id
    end
    add_index :detailed_search_activities, [:activity_id]
    add_index :detailed_search_activities, [:detailed_search_id]

    create_table :detailed_searches do |t|
    end
  end

  def self.down
    drop_table :detailed_search_place_of_births
    drop_table :detailed_search_sectors
    drop_table :detailed_search_activities
    drop_table :detailed_searches
  end
end
