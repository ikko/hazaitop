
namespace :clear do

  desc "clear tax_nr for onkormanyzat"
  task "onkori" => :environment do
    Organization.all(:conditions => "name LIKE '%nkorm%'").each do |o|
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

