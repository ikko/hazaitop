class HoboMigration11 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :number_of_employees, :integer
  end

  def self.down
    remove_column :organizations, :number_of_employees
  end
end
