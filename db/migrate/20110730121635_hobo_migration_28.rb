class HoboMigration28 < ActiveRecord::Migration
  def self.up
    add_column :contracts, :number, :string
    add_column :contracts, :name, :string
    add_column :contracts, :buyer_id, :integer
    add_column :contracts, :seller_id, :integer
    remove_column :contracts, :seller
    remove_column :contracts, :buyer

    add_column :notifications, :name, :string
    add_column :notifications, :issued_at, :date
    change_column :notifications, :number, :string, :limit => 255

    add_index :contracts, [:buyer_id]
    add_index :contracts, [:seller_id]
  end

  def self.down
    remove_column :contracts, :number
    remove_column :contracts, :name
    remove_column :contracts, :buyer_id
    remove_column :contracts, :seller_id
    add_column :contracts, :seller, :string
    add_column :contracts, :buyer, :string

    remove_column :notifications, :name
    remove_column :notifications, :issued_at
    change_column :notifications, :number, :integer

    remove_index :contracts, :name => :index_contracts_on_buyer_id rescue ActiveRecord::StatementInvalid
    remove_index :contracts, :name => :index_contracts_on_seller_id rescue ActiveRecord::StatementInvalid
  end
end
