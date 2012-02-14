class HoboMigration96 < ActiveRecord::Migration
  def self.up
    add_column :org_histories, :parameters, :text

    add_column :person_histories, :parameters, :text
  end

  def self.down
    remove_column :org_histories, :parameters

    remove_column :person_histories, :parameters
  end
end
