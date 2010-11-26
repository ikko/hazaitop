class HoboMigration10 < ActiveRecord::Migration
  def self.up
    drop_table :financial_datas

    create_table :financials do |t|
      t.integer  :year
      t.integer  :balance_sheet_total
      t.integer  :turnover
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id
    end
    add_index :financials, [:organization_id]
  end

  def self.down
    create_table "financial_datas", :force => true do |t|
      t.integer  "year"
      t.integer  "balance_sheet_total"
      t.integer  "turnover"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "organization_id"
    end

    add_index "financial_datas", ["organization_id"], :name => "index_financial_datas_on_organization_id"

    drop_table :financials
  end
end
