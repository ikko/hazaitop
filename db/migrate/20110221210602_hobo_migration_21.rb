# -*- encoding : utf-8 -*-
class HoboMigration21 < ActiveRecord::Migration
  def self.up
    add_column :organizations, :interorg_relations_count, :integer
    add_column :organizations, :person_to_org_relations_count, :integer

    add_column :people, :interpersonal_relations_count, :integer
    add_column :people, :person_to_org_relations_count, :integer


    #    Organization.reset_column_information
    #    Person.reset_column_information
    #
    #    run: rake update:counters
    
  end

  def self.down
    remove_column :organizations, :interorg_relations_count
    remove_column :organizations, :person_to_org_relations_count

    remove_column :people, :interpersonal_relations_count
    remove_column :people, :person_to_org_relations_count
  end
end


class Organization < ActiveRecord::Base
    has_many :interorg_relations
    has_many :person_to_org_relations
end

class Person < ActiveRecord::Base
    has_many :interpersonal_relations
    has_many :person_to_org_relations
end


class InterpersonalRelation < ActiveRecord::Base
    belongs_to :person, :counter_cache => true
end

class InterorgRelation < ActiveRecord::Base
    belongs_to :organization, :counter_cache => true
end

class PersonToOrgRelation < ActiveRecord::Base
    belongs_to :organization, :counter_cache => true
    belongs_to :person, :counter_cache => true
end


