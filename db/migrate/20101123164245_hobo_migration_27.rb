class HoboMigration27 < ActiveRecord::Migration
  def self.up
    create_table :affairs do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :articles do |t|
      t.string   :web
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :interpersonal_relations, :weight, :float

    add_column :interorg_relations, :weight, :float

    add_column :person_to_org_relations, :weight, :float

  end

  def self.down
    remove_column :interpersonal_relations, :weight

    remove_column :interorg_relations, :weight

    remove_column :person_to_org_relations, :weight

    drop_table :affairs
    drop_table :articles

  end
end
