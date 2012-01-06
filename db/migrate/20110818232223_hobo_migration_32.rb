# -*- encoding : utf-8 -*-
class HoboMigration32 < ActiveRecord::Migration
  def self.up
    add_column :interorg_relations, :notification_id, :integer

    add_index :interorg_relations, [:notification_id]
  end

  def self.down
    remove_column :interorg_relations, :notification_id

    remove_index :interorg_relations, :name => :index_interorg_relations_on_notification_id rescue ActiveRecord::StatementInvalid
  end
end

