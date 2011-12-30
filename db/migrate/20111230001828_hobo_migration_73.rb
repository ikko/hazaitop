class HoboMigration73 < ActiveRecord::Migration
  def self.up
    add_column :people, :selected_organization_id, :integer

    add_index :people, [:selected_organization_id]
  end

  def self.down
    remove_column :people, :selected_organization_id

    remove_index :people, :name => :index_people_on_selected_organization_id rescue ActiveRecord::StatementInvalid
  end
end
