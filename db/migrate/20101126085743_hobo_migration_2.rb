class HoboMigration2 < ActiveRecord::Migration
  def self.up
    add_column :litigations, :information_source_id, :integer

    add_index :litigations, [:information_source_id]
  end

  def self.down
    remove_column :litigations, :information_source_id

    remove_index :litigations, :name => :index_litigations_on_information_source_id rescue ActiveRecord::StatementInvalid
  end
end
