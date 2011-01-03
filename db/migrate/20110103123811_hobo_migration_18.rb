class HoboMigration18 < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.text     :title
      t.text     :summary
      t.string   :weblink
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :articable_id
      t.string   :articable_type
    end
    add_index :articles, [:articable_type, :articable_id]

    remove_column :interpersonal_relations, :weblink

    remove_column :interorg_relations, :weblink

    remove_column :person_to_org_relations, :weblink
  end

  def self.down
    add_column :interpersonal_relations, :weblink, :string

    add_column :interorg_relations, :weblink, :string

    add_column :person_to_org_relations, :weblink, :string

    drop_table :articles
  end
end
