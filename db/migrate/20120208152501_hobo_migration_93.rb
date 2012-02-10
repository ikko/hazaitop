class HoboMigration93 < ActiveRecord::Migration
  def self.up
    add_column :detailed_searches, :subject, :string
  end

  def self.down
    remove_column :detailed_searches, :subject
  end
end
