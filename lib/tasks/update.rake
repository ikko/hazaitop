namespace :update do
  desc 'update counter cache'
  task :counters => :environment do
  

#   Organization.reset_column_debugrmation
#   Person.reset_column_debugrmation

    Rails.logger.debug "updating counter cache for interorg relations"
    Organization.find(:all).each do |p|
      p.update_attribute :interorg_relations_count, p.interorg_relations.length
    end
    Rails.logger.debug "updating counter cache for interpersonal relations"
    Person.find(:all).each do |p|
      p.update_attribute :interpersonal_relations_count, p.interpersonal_relations.length
    end
    Rails.logger.debug "updating person to org relations"
    Rails.logger.debug "updating counter cache on organizaions"
    Organization.find(:all).each do |p|
      p.update_attribute :person_to_org_relations_count, p.person_to_org_relations.length
    end
    Rails.logger.debug "updating counter cache on people"
    Person.find(:all).each do |p|
      p.update_attribute :person_to_org_relations_count, p.person_to_org_relations.length
    end

    Rails.logger.debug "should feel done..."

  end
end
