# -*- encoding : utf-8 -*-
namespace :civils do

  desc 'import civil csv data from db/civil_xxxx.txt'
  task :load => :environment do
    info = InformationSource.find_or_create_by_name( "birosag.hu" ) do |w| 
      w.name = "birosag.hu" 
      w.web = "http://www.birosag.hu/engine.aspx?page=tarsszervsearch" 
    end

    rel   = P2oRelationType.find_or_create_by_name("képviselő") do |r| r.name = 'képviselő'; r.parsed = true end
    p_rel = P2pRelationType.find_or_create_by_name("közösen képviselik") do |r| r.name = 'közösen képviselik'; r.parsed = true end
    rel.update_attribute :p2p_relation_type_id, p_rel.id

    birel   = O2oRelationType.find_or_create_by_name("nyilvántartó")   do |r| r.name = 'nyilvántartó'  ; r.parsed = true end
    birel_x = O2oRelationType.find_or_create_by_name("nyilvántartója") do |r| r.name = 'nyilvántartója'; r.parsed = true; r.pair_id = birel.id end
    birel.update_attribute :pair_id, birel_x.id

    (1000..1999).each do |i|
      f = File.open("db/civil_#{i}.txt")
      puts "== #{i} ======================================="
      f.each do |l|
        next if l.blank?
        l = l[5..-1]
        a = l.split('!;!')
        next if a[1].blank?
        org = Organization.find_by_name( a[1] )
        org = Organization.new unless org
        org.name     = a[1] if org.name.blank?
        org.zip_code = a[3] if org.zip_code.blank?
        org.street   = a[7] if org.street.blank?
        org.city     = a[5] if org.city.blank?
        org.description   = a[15] if org.description.blank?
        org.county_id_nr  = a[19] if org.county_id_nr.blank?
        org.country_id_nr = a[21] if org.country_id_nr.blank?
        org.information_source_id = info.id unless org.information_source_id 
        org.civil = true
        start_date = a[27].blank? ? nil : a[27].to_date
        puts org.save
        k = a[9].split(',')
        k.each do |z| 
          z = z.strip
          if !org.people.*.name.include?( z )
            p = Person.create!( :first_name => ( z.split(' ').size > 0 ? z.split(' ')[1..-1].join(' ') : "" ),
                                :last_name  => z.split(' ').first,
                                :information_source_id => info.id
                              )
            pto = PersonToOrgRelation.new( :information_source_id => info.id,
                                         :person_id => p.id,
                                         :organization_id => org.id,
                                         :parsed => true,
                                         :p2o_relation_type_id => rel.id,
                                         :no_end_time => true,
                                         :start_time => start_date
                                       )
            pto.save
          end
        end
        act = Activity.find_or_create_by_name(a[11].strip) do |r| r.name = a[11].strip end
        if !org.activities.include?(act)
          org.activities << act
        end
        act = Activity.find_or_create_by_name(a[13].strip) do |r| r.name = a[13].strip end
        if !org.activities.include?(act)
          org.activities << act
        end

#        bir = Organization.find_or_create_by_name( a[23].strip ) do |b| b.name = a[23].strip; b.information_source_id = info.id end
#        ir = InterorgRelation.find_or_create_by_organization_id_and_related_organization_id_and_name( org.id, bir.id, a[25] ) do |r|
#          r.organization_id = org.id
#          r.related_organization_id = bir.id
#          r.name = a[25]
#          r.start_time = a[27].to_date unless a[27].blank?
#          r.information_source_id = info.id
#          r.o2o_relation_type_id = birel.id
#          r.parsed = true
#        end

        puts org.name

      end
      f.close
    end
  end
=begin
"1010;
0 Szervezet neve!;!
1 Kisgazda Jövő Alapítvány!;!
2 Szervezet székhelye (irsz)!;!
3 1010!;!
4 Szervezet székhelye (település)!;!
5 Budapest!;!
6 Szervezet székhelye (utca, hsz)!;!
7 Mária tér 1.!;!
8 Képviselő(k)!;!
9 Hittig Gusztáv!;!
10 Típus!;!
11 Alapitvány!;!
12 Cél szerinti besorolás!;!
13 szociális tevékenység!;!
14 Cél leírása!;!
15 A magyar fiatalok taníttatásának, továbbképzésüknek, ill. a magyar hazafiak hátrányos helyzetű özvegyeinek a támogatása.!;!
16 Állapot!;!
17 Bejelentés alapján módositott!;!
18 Megyei nyilvántartási szám!;!
19 7209 / 2010!;!
20 Országos nyilvántartásbeli azonosító!;!
21 5913 / 1998!;!
22 Eljárt bíróság neve!;!
23 Fővárosi Bíróság!;!
24 Határozat száma!;!
25 60670 / 1998 . 19!;!
26 Jogerőre emelkedés dátuma!;!
27 2010. 04. 01.!;!!;!!;!"
=end
  desc 'import manual data from db/manual_#{model}.txt'
  task :articles => :environment do
    puts f = File.open('db/manual_articles.txt', 'r')
    f.each do |l|
      next if l.empty?
      l.strip!
      c = l.split(':!:')
      next if c[0].blank? or c[3].blank?
      Article.find_or_create_by_internet_address( c[3].strip ) do |w|
        w.information_source_id = InformationSource.find_by_name(c[1]).id
        w.name     = c[0].strip.gsub("NEWLINE","\n")
        w.summary  = c[2].try.strip.gsub("NEWLINE","\n")
        w.internet_address  = c[3].try.strip
        w.weblink  = c[4].try.strip
        w.processed_at = c[5].blank? ? nil : c[5].to_date
        w.user_id = c[6].blank? ? nil : User.find_by_name(c[6]).id
        puts w.inspect
        puts "......."
      end
    end
    f.close
    puts "exiting..."
  end


  desc 'import manual data from db/manual_#{model}.txt'
  task :person_grades => :environment do
    puts f = File.open('db/manual_person_grades.txt', 'r')
    new_p = 0; p = []; p_ids = []
    sub = false
    puts @info = InformationSource.find_by_name('ahalo.hu')
    f.each do |l|
      next if l.empty?
      l.strip!
      if !sub
        @main = PersonGrade.find_or_create_by_name(l) do |r| r.name = l end
        sub = true
      else
        a = l.split(':+:')
        a.each do |b|
          c = b.split(':!:')
          @sub = Person.find_or_create_by_name( c[0].strip.gsub(',','').gsub('  ',' ') ) do |w|
            w.first_name = c[1].strip
            w.last_name  = c[2].strip
            w.klink      = c[6]
            w.born_at    = (c[7].blank? ? nil : c[7].to_date)
            w.mothers_name=c[8]
            w.information_source_id = @info.id
          end
          if @sub 
            if !@sub.person_grades.include?(@main)
              @sub.person_grades << @main
              puts "added that #{@sub} is #{@main}"
            end
          else
            p << @sub
            p_ids << @sub.id
            new_p += 1
          end
        end
        sub = false
        puts "- - - - - - - "
      end
    end
    puts "#{new_p} new people found: "
    puts p.join(',')
    f.close
    puts "exiting..."
  end


  desc 'import manual data from db/manual_#{model}.txt'
  task :information_sources => :environment do
    puts f = File.open('db/manual_information_sources.txt', 'r')
    sub = false
    f.each do |l|
      next if l.empty?
      l.strip!
      c = l.split(':!:')
      InformationSource.find_or_create_by_name( c[0].strip ) do |w|
        w.name = c[0].strip
        w.web  = c[1].strip
        w.internal = ( c[2].strip == '1' ? true : false )
        puts "creating new source:"
        puts w.inspect
        puts "......."
      end
    end
    f.close
    puts "exiting..."
  end

  desc 'import manual data from db/manual_#{model}.txt'
  task :p2p_relation_types => :environment do
    puts f = File.open('db/manual_p2p_relation_types.txt', 'r')
    sub = false
    f.each do |l|
      l.strip!
      next if l.empty?
      c = l.split(':!:')
      P2pRelationType.find_or_create_by_name( c[0].strip ) do |w|
        w.name = c[0].strip
        w.weight =  c[1].strip.to_f
        w.visual = ( c[2].strip == '1' ? true : false )
        w.litig = ( c[3].strip == '1' ? true : false )
        puts "creating new rel type:"
        puts w.inspect
        puts "......."
      end
    end
    f.close
    puts "exiting..."
  end

  desc 'import manual data from db/manual_#{model}.txt'
  task :o2o_relation_types => :environment do
    puts f = File.open('db/manual_o2o_relation_types.txt', 'r')
    sub = false
    f.each do |l|
      l.strip!
      next if l.empty?
      c = l.split(':!:')
      O2oRelationType.find_or_create_by_name( c[0].strip ) do |w|
        w.name = c[0].strip
        w.weight =  c[1].strip.to_f
        w.visual = ( c[2].strip == '1' ? true : false )
        w.litig = ( c[3].strip == '1' ? true : false )
        puts "creating new rel type:"
        puts w.inspect
        puts "......."
      end
    end
    f.close
    puts "exiting..."
  end
  desc 'import manual data from db/manual_#{model}.txt'
  task :p2o_relation_types => :environment do
    puts f = File.open('db/manual_p2o_relation_types.txt', 'r')
    sub = false
    f.each do |l|
      l.strip!
      next if l.empty?
      c = l.split(':!:')
      P2oRelationType.find_or_create_by_name( c[0].strip ) do |w|
        w.name = c[0].strip
        w.weight =  c[1].strip.to_f
        w.visual = ( c[2].strip == '1' ? true : false )
        w.litig = ( c[3].strip == '1' ? true : false )
        puts "creating new rel type:"
        puts w.inspect
        puts "......."
      end
    end
    f.close
    puts "exiting..."
  end
  desc 'import manual data from db/manual_#{model}.txt'
  task :p2o_relation_types => :environment do
    puts f = File.open('db/manual_p2o_relation_types.txt', 'r')
    sub = false
    f.each do |l|
      l.strip!
      next if l.empty?
      c = l.split(':!:')
      P2oRelationType.find_or_create_by_name( c[0].strip ) do |w|
        w.name = c[0].strip
        w.weight =  c[1].strip.to_f
        w.visual = ( c[2].strip == '1' ? true : false )
        w.litig = ( c[3].strip == '1' ? true : false )
        puts "creating new rel type:"
        puts w.inspect
        puts "......."
      end
    end
    f.close
    puts "exiting..."
  end



  desc 'import manual data from db/manual_#{model}.txt'
  task :people => :environment do
    f = File.open('db/manual_people.txt', 'r')
    f.each do |l|
      l.strip!
      next if l.empty?
      a = l.split(':!:')
      r = nil
      r = Person.find_by_klink( a[1] ) unless a[1].blank?
      if r.nil? 
        r = Person.find_by_name( a[0].strip + ' ' + a[2].strip )
        puts "looking just for name #{a[0].strip + ' ' + a[2].strip}"
      else
        puts "found by klink #{a[1]}"
      end
      if r.nil?
        puts "not found - - - - creating new person"
        r = Person.new
      end
      r.last_name = a[0]
      r.klink = a[1]
      r.first_name = a[2]
      r.born_at = (a[3].blank? ? nil : a[3].to_date)
      r.mothers_name = a[4]
      r.place_of_birth = PlaceOfBirth.find_by_name(a[5])
      r.information_source = InformationSource.find_by_name(a[6])
      r.user = User.find_by_name(a[7])
      r.user = User.find_by_name('Beta') unless r.user
      puts "loading person data..."
      puts r.save
      puts " ____________________________"
    end
    f.close
  end

  desc 'import manual data to db/manual_#{model}.txt'
  task :organizations => :environment do
    f = File.open('db/manual_organizations.txt', 'r')
    f.each do |l|
      l.strip!
      next if l.empty?
      a = l.split(':!:')
      r = nil
      r = Organization.find_by_klink( a[1] ) unless a[1].blank?
      if r.nil? 
        r = Organization.find_by_name( a[0].strip )
        puts "looking just for name #{a[0].strip}"
      else
        puts "found by klink #{a[1]}"
      end
      if r.nil?
        puts "not found - - - - creating new org"
        r = Organization.new
      end
      r.name = a[0]
      r.klink = a[1]
      r.street = a[2]
      r.city = a[3]
      r.zip_code = a[4]
      r.phone = a[5]
      r.fax = a[6]
      r.email_address = a[7]
      r.internet_address = a[8]
      r.information_source = InformationSource.find_by_name(a[9])
      r.user = User.find_by_name(a[10])
      r.user = User.find_by_name('Beta') unless r.user
      puts "loading org data... #{r.inspect}"
      puts r.save
      puts " ____________________________"
    end
    f.close
  end


  desc 'import manual data to db/manual_#{model}.txt'
  task :interpersonal => :environment do
    f = File.open('db/manual_interpersonal_relations.txt', 'r')
    f.each do |l|

     # f.puts("#{r.start_time}:!:#{r.end_time}:!:#{r.no_end_time ? '1' : '0'}:!:#{r.information_source}:!:#{r.related_person.name.gsub(',','')}:!:#{r.person.name.gsub(',','')}:!:#{r.p2p_relation_type}:/:#{r.articles.*.weblink.join(',')}")

      l.strip!
      next if l.empty?

      a = l.split(':!:')

      rp = Person.find_all_by_name a[4]
      p  = Person.find_all_by_name a[5]
      t  = P2pRelationType.find_by_name a[6].split(':/:')[0]


      if p.size > 1
        new_p = []
        p.each do |x|
          if !x.klink.blank?
            new_p << x
          end
        end
        p = new_p
      end

      if rp.size > 1
        new_rp = []
        rp.each do |x|
          if !x.klink.blank?
            new_rp << x
          end
        end
        rp = new_rp
      end

      if rp.size != 1 or p.size != 1
        puts "double people or missing, skipping..."
        puts l
        puts rp.inspect
        puts p.inspect
        puts t.inspect
        puts "waiting..."
        sleep 10
        next
      end

      p = p.first
      rp = rp.first

      r = InterpersonalRelation.find_by_person_id_and_related_person_id_and_p2p_relation_type_id( p.id, rp.id, t.id )
      if r
        puts "relation found skipping... #{a.inspect}"
      else
        puts "not found - - - - creating new realtion"
        r = InterpersonalRelation.new
        r.person_id = p.id
        r.related_person_id = rp.id
        r.p2p_relation_type_id = t.id
        r.start_time = (a[0].blank? ? nil : a[0].to_date)
        r.end_time = (a[1].blank? ? nil : a[1].to_date)
        r.no_end_time = (a[2] == "1" ? true : false)
        r.information_source = InformationSource.find_by_name(a[3])
        r.articles = Article.find_all_by_internet_address( a[6].split(':/:')[1].split(',').each do |l| l.strip! end ) if a[6].split(':/:')[1] 
        puts "loading relation data...#{r.inspect}"
        puts r.save
      end
      puts "____________________________"
    end
    f.close
  end

  desc 'import manual data to db/manual_#{model}.txt'
  task :interorg => :environment do
    f = File.open('db/manual_interorg_relations.txt', 'r')
    f.each do |l|

      l.strip!
      next if l.empty?
      a = l.split(':!:')

      ro = Organization.find_all_by_name a[1]
      o  = Organization.find_all_by_name a[2]
      t  = O2oRelationType.find_by_name a[3].split(':/:')[0]

      if ro.size != 1 or o.size != 1
        puts "double org, skipping..."
        puts l
        puts ro.inspect
        puts o.inspect
        puts t.inspect
        puts "waiting..."
        sleep 10
        next
      end
      
      o = o.first
      ro = ro.first

      r = InterorgRelation.find_by_organization_id_and_related_organization_id_and_o2o_relation_type_id( o.id, ro.id, t.id )
      if r
        puts "relation found skipping... #{a.inspect}"
      else
        puts "not found - - - - creating new realtion"
        r = InterorgRelation.new
        r.organization_id = o.id
        r.related_organization_id = ro.id
        r.o2o_relation_type_id = t.id
        r.no_end_time = true
        r.information_source = InformationSource.find_by_name(a[0])
        r.articles = Article.find_all_by_internet_address( a[3].split(':/:')[1].split(',').each do |l| l.strip! end ) if a[3].split(':/:')[1]
        puts "loading relation data...#{r.inspect}"
        puts r.save
      end
      puts "____________________________"
      
    end
    f.close
  end

  desc 'import manual data to db/manual_#{model}.txt'
  task :person_to_org => :environment do
    f = File.open('db/manual_person_to_org_relations.txt', 'r')
    f.each do |l|

      l.strip!
      next if l.empty?
      a = l.split(':!:')

      # f.puts("#{r.start_time}:!:#{r.end_time}:!:#{r.no_end_time ? '1' : '0'}:!:#{r.information_source}:!:#{r.person.name.gsub(',','')}:!:#{r.organization}:!:#{r.p2o_relation_type}:/:#{r.articles.*.weblink.join(',')}")

      p  = Person.find_all_by_name a[4]
      o  = Organization.find_all_by_name a[5]
      t  = O2oRelationType.find_by_name a[6].split(':/:')[0]

      if p.size > 1
        new_p = []
        p.each do |x|
          if !x.klink.blank?
            new_p << x
          end
        end
        p = new_p
      end

      if p.size != 1 or o.size != 1
        puts "double org or person, skipping..."
        puts l
        puts p.inspect
        puts o.inspect
        puts t.inspect
        puts "waiting..."
        sleep 10
        next
      end
      
      o = o.first
      p = p.first

      r = PersonToOrgRelation.find_by_organization_id_and_person_id_and_p2o_relation_type_id( o.id, p.id, t.id )
      if r
        puts "relation found skipping... #{a.inspect}"
      else
        puts "not found - - - - creating new realtion"
        r = PersonToOrgRelation.new
        r.organization_id = o.id
        r.person_id = p.id
        r.p2o_relation_type_id = t.id
        r.start_time = (a[0].blank? ? nil : a[0].to_date)
        r.end_time = (a[1].blank? ? nil : a[1].to_date)
        r.no_end_time = (a[2] == "1" ? true : false)
        r.information_source = InformationSource.find_by_name(a[3])
        r.articles = Article.find_all_by_internet_address( a[6].split(':/:')[1].split(',').each do |l| l.strip! end ) if a[6].split(':/:')[1]
        puts "loading relation data...#{r.inspect}"
        puts r.save
      end
      puts "____________________________"
      
    end
    f.close
  end
    




end
