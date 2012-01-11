class HoboMigration78 < ActiveRecord::Migration
  def self.up
    # biztos ami biztos
    if Article.first.try.name.present?
      remove_column :articles, :title
    end
  end

  def self.down
    add_column :articles, :title, :text
  end
end
