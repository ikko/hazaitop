namespace :update do
  desc 'update counter cache'
  task :counters => :environment do
  

#   Organization.reset_column_debugrmation
#   Person.reset_column_debugrmation

    Organization.find(:all).each do |p|
      p.update_attribute :interorg_relations_count, p.interorg_relations.length
      p.update_attribute :person_to_org_relations_count, p.person_to_org_relations.length
    end
    Person.find(:all).each do |p|
      p.update_attribute :interpersonal_relations_count, p.interpersonal_relations.length
      p.update_attribute :person_to_org_relations_count, p.person_to_org_relations.length
    end

  end
end
