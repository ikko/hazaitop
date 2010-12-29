class HoboMigration17 < ActiveRecord::Migration
  def self.up
    add_column :interpersonal_relations, :weblink, :string

    add_column :interorg_relations, :weblink, :string

    add_column :person_to_org_relations, :weblink, :string
  end

  def self.down
    remove_column :interpersonal_relations, :weblink

    remove_column :interorg_relations, :weblink

    remove_column :person_to_org_relations, :weblink
  end
end
