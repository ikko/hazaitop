# -*- encoding : utf-8 -*-
class HoboMigration50 < ActiveRecord::Migration
  def self.up
    Person.all.each do |person|
      Person.update_counters person.id, :person_to_org_relations_count => 0 unless person.person_to_org_relations_count
      Person.update_counters person.id, :interpersonal_relations_count => 0 unless person.interpersonal_relations_count
    end
  end

  def self.down
  end
end

