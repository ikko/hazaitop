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
end
