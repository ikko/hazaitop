class HoboMigration40 < ActiveRecord::Migration
  def self.up
    add_column :tenders, :interorg_relation_id, :integer

    add_index :tenders, [:interorg_relation_id]
  end

  def self.down
    remove_column :tenders, :interorg_relation_id

    remove_index :tenders, :name => :index_tenders_on_interorg_relation_id rescue ActiveRecord::StatementInvalid
  end
end
