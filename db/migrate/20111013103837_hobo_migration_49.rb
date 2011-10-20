class HoboMigration49 < ActiveRecord::Migration
  def self.up
    Organization.all.each do |org|
      Organization.update_counters org.id, :person_to_org_relations_count => 0 unless org.person_to_org_relations_count
      Organization.update_counters org.id, :interorg_relations_count => 0 unless org.interorg_relations_count
    end
  end

  def self.down
  end
end
