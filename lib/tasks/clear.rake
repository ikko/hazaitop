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
         o.name.downcase.include?('bt') then
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

