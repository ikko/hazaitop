# -*- encoding : utf-8 -*-
class HoboMigration27 < ActiveRecord::Migration
  def self.up
    create_table :contract_type_rels do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :contract_id
      t.integer  :contract_type_id
    end
    add_index :contract_type_rels, [:contract_id]
    add_index :contract_type_rels, [:contract_type_id]

    create_table :buyer_activity_rels do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id
      t.integer  :buyer_activity_id
    end
    add_index :buyer_activity_rels, [:organization_id]
    add_index :buyer_activity_rels, [:buyer_activity_id]

    create_table :buyer_type_rels do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id
      t.integer  :buyer_type_id
    end
    add_index :buyer_type_rels, [:organization_id]
    add_index :buyer_type_rels, [:buyer_type_id]

    create_table :buyer_types do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :contract_types do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :contracts do |t|
      t.string   :buyer
      t.text     :description
      t.text     :subject_and_qty
      t.string   :seller
      t.integer  :sum_value
      t.integer  :contracted_value
      t.integer  :estimated_value
      t.string   :currency
      t.boolean  :vat_incl
      t.date     :contracting_at
      t.integer  :no_of_other_proposals
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :notification_id
    end
    add_index :contracts, [:notification_id]

    create_table :buyer_activities do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :contract_cpv_rels do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :contract_id
      t.integer  :cpv_id
    end
    add_index :contract_cpv_rels, [:contract_id]
    add_index :contract_cpv_rels, [:cpv_id]

    create_table :contract_frame_rels do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :contract_id
      t.integer  :contract_frame_id
    end
    add_index :contract_frame_rels, [:contract_id]
    add_index :contract_frame_rels, [:contract_frame_id]

    create_table :notifications do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean  :processed, :default => false
      t.integer  :number
      t.integer  :site_id
    end

    create_table :cpvs do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :contract_frames do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :organizations, :phone, :string
    add_column :organizations, :fax, :string
    add_column :organizations, :email_address, :string
    add_column :organizations, :internet_address, :string

    add_column :interorg_relations, :value, :integer
    add_column :interorg_relations, :currency, :string
    add_column :interorg_relations, :vat_incl, :boolean
    add_column :interorg_relations, :contract_id, :integer

    add_index :interorg_relations, [:contract_id]
  end

  def self.down
    remove_column :organizations, :phone
    remove_column :organizations, :fax
    remove_column :organizations, :email_address
    remove_column :organizations, :internet_address

    remove_column :interorg_relations, :value
    remove_column :interorg_relations, :currency
    remove_column :interorg_relations, :vat_incl
    remove_column :interorg_relations, :contract_id

    drop_table :contract_type_rels
    drop_table :buyer_activity_rels
    drop_table :buyer_type_rels
    drop_table :buyer_types
    drop_table :contract_types
    drop_table :contracts
    drop_table :buyer_activities
    drop_table :contract_cpv_rels
    drop_table :contract_frame_rels
    drop_table :notifications
    drop_table :cpvs
    drop_table :contract_frames

    remove_index :interorg_relations, :name => :index_interorg_relations_on_contract_id rescue ActiveRecord::StatementInvalid
  end
end

