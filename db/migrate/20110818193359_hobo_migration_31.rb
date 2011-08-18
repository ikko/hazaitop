class HoboMigration31 < ActiveRecord::Migration
  def self.up
    add_column :articles, :processed_at, :date
    add_column :articles, :user_id, :integer

    add_index :articles, [:user_id]
  end

  def self.down
    remove_column :articles, :processed_at
    remove_column :articles, :user_id

    remove_index :articles, :name => :index_articles_on_user_id rescue ActiveRecord::StatementInvalid
  end
end
