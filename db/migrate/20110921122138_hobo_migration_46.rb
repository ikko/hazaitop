# -*- encoding : utf-8 -*-
class HoboMigration46 < ActiveRecord::Migration
  def self.up
    add_column :articles, :state, :string, :default => "normal"
    add_column :articles, :key_timestamp, :datetime

    add_index :articles, [:state]
  end

  def self.down
    remove_column :articles, :state
    remove_column :articles, :key_timestamp

    remove_index :articles, :name => :index_articles_on_state rescue ActiveRecord::StatementInvalid
  end
end

