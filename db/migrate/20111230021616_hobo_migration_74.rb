# -*- encoding : utf-8 -*-
class HoboMigration74 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :search_result_count, :integer, :default => 0

    add_column :interorg_relations, :search_result_count, :integer, :default => 0

    add_column :litigations, :search_result_count, :integer, :default => 0

    add_column :people, :search_result_count, :integer, :default => 0

    add_column :articles, :search_result_count, :integer, :default => 0
  end

  def self.down
    remove_column :organizations, :search_result_count

    remove_column :interorg_relations, :search_result_count

    remove_column :litigations, :search_result_count

    remove_column :people, :search_result_count

    remove_column :articles, :search_result_count
  end
end

