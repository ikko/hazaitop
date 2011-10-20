class HoboMigration47 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :merge_from_id, :integer

    add_index :organizations, [:merge_from_id]
  end

  def self.down
    remove_column :organizations, :merge_from_id

    remove_index :organizations, :name => :index_organizations_on_merge_from_id rescue ActiveRecord::StatementInvalid
  end
end
