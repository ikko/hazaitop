# -*- encoding : utf-8 -*-
namespace :clear do
  desc "set company tag for company orgs"
  task "company" => :environment do
    Organization.all.each do |o|
      if o.name.downcase.include?('kft') or
         o.name.downcase.include?('rt') or
         o.name.downcase.include?('rsas') or #
         o.name.downcase.include?('llalat') or
         o.name.downcase.include?('nyomda') or
         o.name.downcase.include?('bt') or
         o.name.downcase.include?('bank') then
        o.company = true
      else
        o.tax_nr = nil
        o.trade_register_nr = nil
      end
      puts o.name
      puts o.save
    end
  end

  desc "strip all articles"
  task "article" => :environment do
    Article.all.each do |a|
      a.name = a.name.try.strip
      a.summary = a.summary.try.strip
      a.save
    end
  end

  desc "clear tax_nr for onkormanyzat"
  task "onkori" => :environment do
    Organization.all(:conditions => "name LIKE '%intézmény%' or 
                                     name LIKE '%nkorm%' or 
                                     name LIKE '%egyéni vállalkozó%' or 
                                     name LIKE '%iskola%' or 
                                     name LIKE '%óvoda%'" ).each do |o|
      puts o.name
      o.tax_nr = nil
      o.trade_register_nr = nil
      o.save
    end
  end


  desc "strip organization white spaces"
  task "orgs" => :environment do
    counter = 97 # 'a'
    puts 'a'
    n = 0
    Organization.all.each do |o|
      if o.name[0] > counter
        counter = o.name[0]
        puts o.name[0..0]
      end
      if o.street.try.strip != o.street
        o.street = o.street.strip
        o.save
        n += 1
      end
      if o.city.try.strip != o.city
        o.city = o.city.strip
        o.save
        n += 1
      end
      if o.name.try.strip != o.name
        o.name = o.name.strip
        o.save
        n += 1
      end
    end
    puts "#{n} change has been made"
  end

  desc 'merge orgs with same tax_nr'
  task :tax_nr => :environment do
    n = 0
    puts "starting the merge..."
    Organization.tax_nr_is_not("").each do |o|
      same_orgs = Organization.find_all_by_tax_nr(o.tax_nr)
      same_orgs.each do |so|
        if o.id != so.id
          puts "merging #{so.id}:#{so.name}"
          puts "into  #{o.id}:#{o.name}"
          puts Organization.merge o, so
          n += 1
        end
      end
    end
    outs "#{n} merge done."
  end

end

