namespace :update do
  desc 'update counter cache'
  task :counters => :environment do
  
    Organization.all.each do |p|
      p.update_attributes :interorg_relations_count => p.interorg_relations.length, :person_to_org_relations_count => p.person_to_org_relations.length
    end
    Person.all.each do |p|
      p.update_attributes :interpersonal_relations_count => p.interpersonal_relations.length, :person_to_org_relations_count => p.person_to_org_relations.length
    end

  end

  desc 'update parsed bit cache'
  task :parsed => :environment do
    puts "1"
    InterpersonalRelation.all.each do |r| r.p2p_relation_type.parsed? ? r.update_attribute :parsed, true : r.update_attribute :parsed, false  end
    puts "2"
    InterorgRelation.all.each do |r|      r.o2o_relation_type.parsed? ? r.update_attribute :parsed, true : r.update_attribute :parsed, false  end
    puts "3"
    PersonToOrgRelation.all.each do |r|   r.p2o_relation_type.parsed? ? r.update_attribute :parsed, true : r.update_attribute :parsed, false  end
    puts "4"
  end
end
