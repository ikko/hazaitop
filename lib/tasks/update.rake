# -*- encoding : utf-8 -*-
namespace :update do

  desc 'update relations counter'
  task :counters => :environment do
#     Organization.all.each do |p| p.save end
#     Person.all.each do |p| puts "#{p.id}: #{p.save}" end
    for i in 0..300
      puts i
      puts "a"
      InterpersonalRelation.find(:all, :include => :person, :conditions => ["id >= #{i}001 and id < #{i+1}000"]).each do |r| 
        if !r.person or !r.related_person then puts r.destroy end
      end
      puts "b"
      InterorgRelation.find(:all, :include => :organization, :conditions => ["id >= #{i}001 and id < #{i+1}000"]).each do |r|
        if !r.related_organization or !r.organization then puts r.destroy end
      end
      puts "c"
      PersonToOrgRelation.find(:all, :include => [:person, :organization], :conditions => ["id >= #{i}001 and id < #{i+1}000"]).each do |r|
        r.save
        if !r.person or !r.organization then puts r.destroy end
      end
      puts "--------------------------"
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
    Organization.all.each do |r|
      if r.name.strip != r.name
        r.update_attribute :name, r.name.strip
        puts r.name.strip
      end
      if r.name.include?('"')
        r.save
      end
    end

    def clean x
      return true if x.blank?
      x = x.downcase
      return true if x.include?("budapest")
      return true if x.include?(" út")
      return true if x.include?(" utca")
      return true if x.include?(" u.")
      return true if x.include?("hrsz")

      return false if x.include?("\n")
      return false if x.include?("\r")
      return false if x.split(' ').size > 10
      return false if x.size < 3
      return false if x.include?('2011')
      return false if x.include?('2010')
      return false if x.include?(' és ')
      return false if x.include?(' határozat ')
      return false if x.include?(' jogok ')
      return false if x.include?(' főváros ')
      return false if x.include?(' ismeretterjeszt ')
      true
    end

    Organization.all.each do |r|
      r.update_attribute :street, nil   unless clean r.street
      r.update_attribute :city, nil     unless clean r.city
      r.update_attribute :zip_code, nil unless clean r.zip_code
    end

=begin
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
=end
  end


  desc 'update cpv descriptions from db/cpv_codes.txt'
  task :cpv => :environment do
    f = File.open("db/cpv_codes.txt", "r")
    c = []
    f.each do |l|
      next if l.strip.empty?
      a = l.split('  ')
      Cpv.find_by_name(a[0]).try.update_attribute :description, a[1]
    end
  end

end
