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
    x = InformationSource.count
    InformationSource.all.each do |r| 
      f.puts("#{r.name}:!:#{r.web}:!:#{r.internal ? '1' : '0'}")
      n += 1
      puts "saving information source #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end

  desc 'export manual data to db/manual_#{model}.txt'
  task :p2p_relation_types => :environment do
    f = File.open('db/manual_p2p_relation_types.txt', 'w')
    n = 0
    x = P2pRelationType.count
    P2pRelationType.all.each do |r| 
      f.puts("#{r.name}:!:#{r.weight}:!:#{r.visual ? '1' : '0'}:!:#{r.litig ? '1' : '0'}")
      n += 1
      puts "saving p2p rel type #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end


  desc 'export manual data to db/manual_#{model}.txt'
  task :o2o_relation_types => :environment do
    f = File.open('db/manual_o2o_relation_types.txt', 'w')
    n = 0
    x = O2oRelationType.count
    O2oRelationType.all.each do |r| 
      f.puts("#{r.name}:!:#{r.weight}:!:#{r.visual ? '1' : '0'}:!:#{r.litig ? '1' : '0'}")
      n += 1
      puts "saving o2o rel type #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end

  desc 'export manual data to db/manual_#{model}.txt'
  task :p2o_relation_types => :environment do
    f = File.open('db/manual_p2o_relation_types.txt', 'w')
    n = 0
    x = P2oRelationType.count
    P2oRelationType.all.each do |r| 
      f.puts("#{r.name}:!:#{r.weight}:!:#{r.visual ? '1' : '0'}:!:#{r.litig ? '1' : '0'}")
      n += 1
      puts "saving p2o rel type #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end

  desc 'export manual data to db/manual_#{model}.txt'
  task :o2p_relation_types => :environment do
    f = File.open('db/manual_o2p_relation_types.txt', 'w')
    n = 0
    x = O2pRelationType.count
    O2pRelationType.all.each do |r| 
      f.puts("#{r.name}:!:#{r.weight}:!:#{r.visual ? '1' : '0'}:!:#{r.litig ? '1' : '0'}")
      n += 1
      puts "saving o2p rel type #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end

  desc 'export manual data to db/manual_#{model}.txt'
  task :people => :environment do
    f = File.open('db/manual_people.txt', 'w')
    n = 0
    x = Person.count
    Person.all.each do |r|
      a = r.interpersonal_relations.not_mirror.*.p2p_relation_type_id
      b = r.person_to_org_relations.*.p2o_relation_type_id
      n += 1
      if !(a - [ 5 ]).empty? or !(b - [ 1 ]).empty?
        f.puts("#{r.last_name}:!:#{r.klink}:!:#{r.first_name}:!:#{r.born_at}:!:#{r.mothers_name}:!:#{r.place_of_birth}:!:#{r.information_source}:!:#{r.user}")
        puts "saving person #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
      end
    end
    f.close
  end

  desc 'export manual data to db/manual_#{model}.txt'
  task :organizations => :environment do
    f = File.open('db/manual_organizations.txt', 'w')
    n = 0
    x = Organization.count
    Organization.all.each do |r| 
      a = r.interorg_relations.not_mirror.*.o2o_relation_type_id
      b = r.person_to_org_relations.*.p2o_relation_type_id
      n += 1
      if !(a - [ 2,15,16,18,19 ]).empty? or !(b - [ 1 ]).empty?
        f.puts("#{r.name}:!:#{r.klink}:!:#{r.street}:!:#{r.city}:!:#{r.zip_code}:!:#{r.phone}:!:#{r.fax}:!:#{r.email_address}:!:#{r.internet_address}:!:#{r.information_source}:!:#{r.user}")
        puts "saving org #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
      end
    end
    f.close
  end


  desc 'export manual data to db/manual_#{model}.txt'
  task :interpersonal => :environment do
    f = File.open('db/manual_interpersonal_relations.txt', 'w')
    n = 0
    x = InterpersonalRelation.count
    InterpersonalRelation.p2p_relation_type_is_not(5).not_internal.each do |r| 
      n += 1
      if r.person and r.related_person
        f.puts("#{r.start_time}:!:#{r.end_time}:!:#{r.no_end_time ? '1' : '2'}:!:#{city}:!:#{r.zip_code}:!:#{r.phone}:!:#{r.fax}:!:#{r.email_address}:!:#{r.internet_address}:!:#{r.information_source}:!:#{r.user}:!:#{r.related_person}:!:#{r.person}:/:#{r.articles.*.weblink.join(',')}")
        puts "saving interpersonal_relation #{r.name} ... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
      end
    end
    f.close
  end

end
