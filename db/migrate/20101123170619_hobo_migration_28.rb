class HoboMigration28 < ActiveRecord::Migration
  def self.up
    create_table :place_of_births do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :people, :place_of_birth_id, :integer

    add_index :people, [:place_of_birth_id]
  end

  def self.down
    remove_column :people, :place_of_birth_id

    drop_table :place_of_births

    remove_index :people, :name => :index_people_on_place_of_birth_id rescue ActiveRecord::StatementInvalid
  end
end
