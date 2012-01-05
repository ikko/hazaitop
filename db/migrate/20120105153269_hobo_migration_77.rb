class HoboMigration76 < ActiveRecord::Migration
  def self.up
    Article.update_all("name=title")
  end

  def self.down
  end
end
