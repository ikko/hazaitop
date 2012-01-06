# -*- encoding : utf-8 -*-
class HoboMigration68 < ActiveRecord::Migration
  def self.up
    create_table :trade_register_numbers do |t|
      t.date     :start_time
      t.date     :end_time
      t.string   :nr
      t.text     :note
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id
    end
    add_index :trade_register_numbers, [:organization_id]

    create_table :liquidations do |t|
      t.date     :start_time
      t.date     :end_time
      t.text     :note
      t.boolean  :stays, :default => false
      t.boolean  :simple, :default => false
      t.date     :process_start
      t.date     :process_end
      t.string   :type
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id
    end
    add_index :liquidations, [:organization_id]

    add_column :interpersonal_relations, :erased_at, :date

    add_column :organizations, :ceased_at, :date
    add_column :organizations, :ceased_from, :date
    add_column :organizations, :kozhasznu, :boolean
    add_column :organizations, :kozhasznu_from, :date
    add_column :organizations, :kiemelten_kozhasznu, :boolean
    add_column :organizations, :kiemelten_kozhasznu_from, :date

    add_column :financials, :start_time, :date
    add_column :financials, :end_time, :date
    add_column :financials, :szorzo, :integer, :limit => 8
    add_column :financials, :penznem, :string
    add_column :financials, :a_eredm, :integer, :limit => 8
    add_column :financials, :aktiv_el, :integer, :limit => 8
    add_column :financials, :eszk, :integer, :limit => 8
    add_column :financials, :celtart, :integer, :limit => 8
    add_column :financials, :netto, :integer, :limit => 8
    add_column :financials, :forgo, :integer, :limit => 8
    add_column :financials, :kotelez, :integer, :limit => 8
    add_column :financials, :m_eredm, :integer, :limit => 8
    add_column :financials, :passziv_el, :integer, :limit => 8
    add_column :financials, :toke, :integer, :limit => 8
    add_column :financials, :u_eredm, :integer, :limit => 8
    add_column :financials, :labj, :text

    add_column :interorg_relations, :erased_at, :date
    add_column :interorg_relations, :note, :text
    add_column :interorg_relations, :role, :string
    add_column :interorg_relations, :role2, :string
    add_column :interorg_relations, :jelentos, :boolean, :default => false
    add_column :interorg_relations, :tobbsegi, :boolean, :default => false
    add_column :interorg_relations, :kozvetlen, :boolean, :default => false
    add_column :interorg_relations, :szavazat_50_szazalek_felett, :boolean, :default => false
    add_column :interorg_relations, :szavazat_tobbsegi_befolyas, :boolean, :default => false
    add_column :interorg_relations, :szavazat_egyeduli_reszvenyes, :boolean, :default => false

    add_column :person_to_org_relations, :role2, :string
    add_column :person_to_org_relations, :note, :text
    add_column :person_to_org_relations, :erased_at, :date
    add_column :person_to_org_relations, :jelentos, :boolean, :default => false
    add_column :person_to_org_relations, :tobbsegi, :boolean, :default => false
    add_column :person_to_org_relations, :kozvetlen, :boolean, :default => false
    add_column :person_to_org_relations, :szavazat_50_szazalek_felett, :boolean, :default => false
    add_column :person_to_org_relations, :szavazat_tobbsegi_befolyas, :boolean, :default => false
    add_column :person_to_org_relations, :szavazat_egyeduli_reszvenyes, :boolean, :default => false

    add_column :people, :mothers_name_alternate, :string
  end

  def self.down
    remove_column :interpersonal_relations, :erased_at

    remove_column :organizations, :ceased_at
    remove_column :organizations, :ceased_from
    remove_column :organizations, :kozhasznu
    remove_column :organizations, :kozhasznu_from
    remove_column :organizations, :kiemelten_kozhasznu
    remove_column :organizations, :kiemelten_kozhasznu_from

    remove_column :financials, :start_time
    remove_column :financials, :end_time
    remove_column :financials, :szorzo
    remove_column :financials, :penznem
    remove_column :financials, :a_eredm
    remove_column :financials, :aktiv_el
    remove_column :financials, :eszk
    remove_column :financials, :celtart
    remove_column :financials, :netto
    remove_column :financials, :forgo
    remove_column :financials, :kotelez
    remove_column :financials, :m_eredm
    remove_column :financials, :passziv_el
    remove_column :financials, :toke
    remove_column :financials, :u_eredm
    remove_column :financials, :labj

    remove_column :interorg_relations, :erased_at
    remove_column :interorg_relations, :note
    remove_column :interorg_relations, :role
    remove_column :interorg_relations, :role2
    remove_column :interorg_relations, :jelentos
    remove_column :interorg_relations, :tobbsegi
    remove_column :interorg_relations, :kozvetlen
    remove_column :interorg_relations, :szavazat_50_szazalek_felett
    remove_column :interorg_relations, :szavazat_tobbsegi_befolyas
    remove_column :interorg_relations, :szavazat_egyeduli_reszvenyes

    remove_column :person_to_org_relations, :role2
    remove_column :person_to_org_relations, :note
    remove_column :person_to_org_relations, :erased_at
    remove_column :person_to_org_relations, :jelentos
    remove_column :person_to_org_relations, :tobbsegi
    remove_column :person_to_org_relations, :kozvetlen
    remove_column :person_to_org_relations, :szavazat_50_szazalek_felett
    remove_column :person_to_org_relations, :szavazat_tobbsegi_befolyas
    remove_column :person_to_org_relations, :szavazat_egyeduli_reszvenyes

    remove_column :people, :mothers_name_alternate

    drop_table :trade_register_numbers
    drop_table :liquidations
  end
end

