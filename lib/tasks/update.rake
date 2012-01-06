# -*- encoding : utf-8 -*-
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

  desc 'strip newlines...'
  task :strip => :environment do
=begin
    Organization.all.each do |r|
      if r.name.strip != r.name
        r.update_attribute :name, r.name.strip
        puts r.name.strip
      end
    end
=end

    def clean x
      return true if x.blank?

      return true if x.include?("Budapest")
      return true if x.include?(" út")
      return true if x.include?(" utca")
      return true if x.include?(" tér")

      return false if x.include?("\n")
      return false if x.include?("\r")
      return false if x.split(' ').size > 10
      return false if x.size < 3
      true
    end

    Organization.all.each do |r|
      r.update_attribute :street, ''  unless clean r.street
      r.update_attribute :city, ''    unless clean r.city
      r.update_attribute :zip_code,'' unless clean r.zip_code
    end


    Article.all.each do |r|
      if r.summary.strip != r.summary
        r.update_attribute :summary, r.summary.strip
      end
      if r.name.strip != r.name
        r.update_attribute :name, r.name.strip
      end
    end


    x = Tender.count
    n = 0
    Tender.all.each do |r|
      n += 1
      if r.unique_string != r.applicant.name + r.op_name.try.to_s.strip + r.name.try.to_s.strip + r.decided_at.to_s + r.amount.to_i.to_s 
        puts "progress #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
        r.update_attribute :unique_string, r.applicant.name + r.op_name.try.to_s.strip + r.name.try.to_s.strip + r.decided_at.to_s + r.amount.to_s
      end
    end
  end
end
