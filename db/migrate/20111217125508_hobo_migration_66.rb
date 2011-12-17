class HoboMigration66 < ActiveRecord::Migration
  def self.up
    create_table :announcements do |t|
      t.date     :start_time
      t.date     :end_time
      t.text     :content
      t.string   :labjegyezet
      t.string   :tipus
      t.string   :tipusnev
      t.date     :issued_at
      t.string   :ugyszam
      t.string   :eugyszam
      t.string   :birosag
      t.string   :felszamolo_neve
      t.string   :felszamolo_cime
      t.string   :felszamolo_cgjsz
      t.string   :felszbizt1_nev
      t.string   :felszbizt1_cim
      t.string   :felszbizt1_irsz
      t.string   :felszbizt2_nev
      t.string   :felszbizt2_cim
      t.string   :felszbizt2_irsz
      t.date     :legal_at
      t.date     :submitted_at
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id
    end
    add_index :announcements, [:organization_id]

    add_column :o2o_relation_types, :role, :string

    add_column :organizations, :alternate_name, :string

    add_column :interorg_relations, :start_time, :date
    add_column :interorg_relations, :end_time, :date
    add_column :interorg_relations, :no_end_time, :boolean, :default => false
  end

  def self.down
    remove_column :o2o_relation_types, :role

    remove_column :organizations, :alternate_name

    remove_column :interorg_relations, :start_time
    remove_column :interorg_relations, :end_time
    remove_column :interorg_relations, :no_end_time

    drop_table :announcements
  end
end
