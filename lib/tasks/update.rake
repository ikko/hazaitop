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
    for i in 0..300
      puts i
      puts "a"
      InterpersonalRelation.find(:all, :include => :p2p_relation_type, :conditions => ["id >= #{i}001 and id < #{i+1}000"]).each do |r| r.p2p_relation_type.parsed? ? r.update_attribute(:parsed, true) : r.update_attribute(:parsed, false) end
      puts "b"
      InterorgRelation.find(:all, :include => :o2o_relation_type, :conditions => ["id >= #{i}001 and id < #{i+1}000"]).each do |r|      r.o2o_relation_type.parsed? ? r.update_attribute(:parsed, true) : r.update_attribute(:parsed, false) end
      puts "c"
      PersonToOrgRelation.find(:all, :include => :p2o_relation_type, :conditions => ["id >= #{i}001 and id < #{i+1}000"]).each do |r|   r.p2o_relation_type.parsed? ? r.update_attribute(:parsed, true) : r.update_attribute(:parsed, false) end
      puts "d"

      puts "--------------------------"
    end
  end
end
