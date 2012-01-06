# -*- encoding : utf-8 -*-
class HoboMigration39 < ActiveRecord::Migration
  def self.up
    add_column :tenders, :name, :string
    add_column :tenders, :information_source_id, :integer
    add_column :tenders, :applicant_id, :integer
    add_column :tenders, :caller_id, :integer
    change_column :tenders, :decision_score, :float, :limit => nil

    add_index :tenders, [:information_source_id]
    add_index :tenders, [:applicant_id]
    add_index :tenders, [:caller_id]
  end

  def self.down
    remove_column :tenders, :name
    remove_column :tenders, :information_source_id
    remove_column :tenders, :applicant_id
    remove_column :tenders, :caller_id
    change_column :tenders, :decision_score, :integer

    remove_index :tenders, :name => :index_tenders_on_information_source_id rescue ActiveRecord::StatementInvalid
    remove_index :tenders, :name => :index_tenders_on_applicant_id rescue ActiveRecord::StatementInvalid
    remove_index :tenders, :name => :index_tenders_on_caller_id rescue ActiveRecord::StatementInvalid
  end
end

