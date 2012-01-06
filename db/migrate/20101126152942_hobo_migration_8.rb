# -*- encoding : utf-8 -*-
class HoboMigration8 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :org_grade_id, :integer

    add_column :activity_assocs, :activity_id, :integer
    add_column :activity_assocs, :organization_id, :integer

    add_index :organizations, [:org_grade_id]

    add_index :activity_assocs, [:activity_id]
    add_index :activity_assocs, [:organization_id]
  end

  def self.down
    remove_column :organizations, :org_grade_id

    remove_column :activity_assocs, :activity_id
    remove_column :activity_assocs, :organization_id

    remove_index :organizations, :name => :index_organizations_on_org_grade_id rescue ActiveRecord::StatementInvalid

    remove_index :activity_assocs, :name => :index_activity_assocs_on_activity_id rescue ActiveRecord::StatementInvalid
    remove_index :activity_assocs, :name => :index_activity_assocs_on_organization_id rescue ActiveRecord::StatementInvalid
  end
end

