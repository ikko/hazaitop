class HoboMigration5 < ActiveRecord::Migration
  def self.up
    add_column :organization_grade_assocs, :organization_id, :integer
    add_column :organization_grade_assocs, :org_grade_id, :integer

    add_column :organizations, :street, :string
    add_column :organizations, :city, :string
    remove_column :organizations, :street1
    remove_column :organizations, :street2

    add_index :organization_grade_assocs, [:organization_id]
    add_index :organization_grade_assocs, [:org_grade_id]

    add_index :interpersonal_relation_calculators, [:related_p2o_relation_type_id], :name => 'matrix'
  end

  def self.down
    remove_column :organization_grade_assocs, :organization_id
    remove_column :organization_grade_assocs, :org_grade_id

    remove_column :organizations, :street
    remove_column :organizations, :city
    add_column :organizations, :street1, :string
    add_column :organizations, :street2, :string

    remove_index :organization_grade_assocs, :name => :index_organization_grade_assocs_on_organization_id rescue ActiveRecord::StatementInvalid
    remove_index :organization_grade_assocs, :name => :index_organization_grade_assocs_on_org_grade_id rescue ActiveRecord::StatementInvalid

    remove_index :interpersonal_relation_calculators, :name => :matrix rescue ActiveRecord::StatementInvalid
  end
end
