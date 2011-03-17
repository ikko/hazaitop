class HoboMigration22 < ActiveRecord::Migration
  def self.up
    add_column :articles, :information_source_id, :integer

    add_index :articles, [:information_source_id]
  end

  def self.down
    remove_column :articles, :information_source_id

    remove_index :articles, :name => :index_articles_on_information_source_id rescue ActiveRecord::StatementInvalid
  end
end
