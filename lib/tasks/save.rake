namespace :save do


  desc 'export org data to  db/orgs.txt'
  task :orgs => :environment do
    f = File.open('db/orgs.txt', 'w')
    n = 0
    x = Organization.count
    Organization.all.each do |r| 
      f.puts("#{r.name}:!:#{r.klink}:!:#{r.street}:!:#{r.city}:!:#{r.zip_code}:!:#{r.phone}:!:#{r.fax}:!:#{r.email_address}:!:#{r.internet_address}:!:#{r.trade_register_nr}:!:#{r.tax_nr}")
      n += 1
      puts "saving org #{r.name[0..40]}... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end

  desc 'export manual data to db/manual_#{model}.txt'
  task :person_grades => :environment do
    f = File.open('db/manual_person_grades.txt', 'w')
    n = 0
    x = PersonGrade.count
    PersonGrade.all.each do |r| 
      f.puts("#{r.name}")
      s = ""
      r.people.each do |w|
        s << "#{w.name.gsub(',','')}:!:#{w.first_name}:!:#{w.last_name}:!:#{w.klink}:!:#{w.born_at}:!:#{w.mothers_name}:+:"
      end
      f.puts(s)                        
      n += 1
      puts "saving person grade #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end

  desc 'export manual data to db/manual_#{model}.txt'
  task :information_sources => :environment do
    f = File.open('db/manual_information_sources.txt', 'w')
    n = 0
    x = PersonGrade.count
    InformationSource.all.each do |r| 
      f.puts("#{r.name}:!:#{r.web}:!:#{r.internal ? '1' : '0'}")
      n += 1
      puts "saving information source #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end
end
