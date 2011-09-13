class HoboMigration41 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :tender_id, :integer

    add_index :interorg_relations, [:tender_id]
  end

  def self.down
    remove_column :interorg_relations, :tender_id

    remove_index :interorg_relations, :name => :index_interorg_relations_on_tender_id rescue ActiveRecord::StatementInvalid
  end
end
