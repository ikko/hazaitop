# -*- encoding : utf-8 -*-
class HoboMigration23 < ActiveRecord::Migration
  def self.up
    add_column :information_sources, :domain_name, :string
    change_column :information_sources, :weight, :float, :default => 1

    add_column :articles, :internet_address, :string

    add_index :article_relations, [:relationable_id]
  end

  def self.down
    remove_column :information_sources, :domain_name
    change_column :information_sources, :weight, :float

    remove_column :articles, :internet_address

    remove_index :article_relations, :name => :index_article_relations_on_relationable_id rescue ActiveRecord::StatementInvalid
  end
end

