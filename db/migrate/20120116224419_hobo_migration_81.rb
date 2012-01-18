class HoboMigration81 < ActiveRecord::Migration
  def self.up
    add_column :detailed_searches, :query, :string
    add_column :detailed_searches, :date_from, :date
    add_column :detailed_searches, :date_to, :date
    add_column :detailed_searches, :person, :boolean, :default => true
    add_column :detailed_searches, :organization, :boolean, :default => true
    add_column :detailed_searches, :article, :boolean, :default => true
    add_column :detailed_searches, :litigation, :boolean, :default => true
    add_column :detailed_searches, :transaction, :boolean
  end

  def self.down
    remove_column :detailed_searches, :query
    remove_column :detailed_searches, :date_from
    remove_column :detailed_searches, :date_to
    remove_column :detailed_searches, :person
    remove_column :detailed_searches, :organization
    remove_column :detailed_searches, :article
    remove_column :detailed_searches, :litigation
    remove_column :detailed_searches, :transaction
  end
end
