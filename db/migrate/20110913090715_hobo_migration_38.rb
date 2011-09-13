class HoboMigration38 < ActiveRecord::Migration
  def self.up
    create_table :tenders do |t|
      t.string   :project
      t.string   :op_name
      t.integer  :amount, :limit => 8
      t.integer  :subsidy
      t.string   :currency
      t.string   :city
      t.string   :county
      t.string   :region
      t.date     :decided_at
      t.integer  :decision_score
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
    end
    add_index :tenders, [:user_id]
  end

  def self.down
    drop_table :tenders
  end
end
