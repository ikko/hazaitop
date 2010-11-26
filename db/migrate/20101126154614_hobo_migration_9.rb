class HoboMigration9 < ActiveRecord::Migration
  def self.up
    drop_table :organization_grade_assocs

    create_table :financial_datas do |t|
      t.integer  :year
      t.integer  :balance_sheet_total
      t.integer  :turnover
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id
    end
    add_index :financial_datas, [:organization_id]
  end

  def self.down
    create_table "organization_grade_assocs", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "organization_id"
      t.integer  "org_grade_id"
    end

    add_index "organization_grade_assocs", ["org_grade_id"], :name => "index_organization_grade_assocs_on_org_grade_id"
    add_index "organization_grade_assocs", ["organization_id"], :name => "index_organization_grade_assocs_on_organization_id"

    drop_table :financial_datas
  end
end
