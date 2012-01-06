# -*- encoding : utf-8 -*-
class HoboMigration75 < ActiveRecord::Migration
  def self.up
    add_column :people, :merge_from_id, :integer

    add_index :people, [:merge_from_id]
  end

  def self.down
    remove_column :people, :merge_from_id

    remove_index :people, :name => :index_people_on_merge_from_id rescue ActiveRecord::StatementInvalid
  end
end

