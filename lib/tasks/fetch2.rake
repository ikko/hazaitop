# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'open-uri'

namespace :fetch2 do
  desc 'fetch ertesito'
  task :ertesito => :environment do

    require 'pdftohtmlr'
    include PDFToHTMLR

    LMAX = 4000


    # helper functions should be separeted later TODO
    def get_pos( what, where )
      for i in 1..(LMAX*3) do
        next if @lines_size -1 < where + i
        begin
          if @lines[ where + i ][0..what.size-1] == what
            return where + i
          end
        rescue
          return nil
        end
      end
      nil
    end

    def look( what, where )
      for i in 1..LMAX do 
        next if @lines_size -1 < where + i
        if @lines[ where + i ][0..what.size-1] == what
          next if @lines[ where + i + 1 ] == "NUTS-kód"  # nasty hack, ez a teljesítés helyére vonatkozik c_telj_helye
          return @lines[ where + i + 1 ]
        end
      end
    end

    def look_between( this, that, where )
      result = ''
      counter = 1
      for i in 1..LMAX do 
        next if @lines_size -1 < where + i
        if @lines[ where + i ][0..this.size-1] == this
          next if @lines_size -1 < where + i + counter
          while @lines[ where + i + counter][0..that.size-1] != that do
            result << @lines[ where + i + counter]
            result << "\n"
            counter += 1
            break if @lines_size -1 < where + i + counter
          end
          return result
        end
      end
    end

    def look_x_before_between( this, that, where )
      result  = []
      counter = 1
      for i in 1..LMAX do 
        next if @lines_size -1 < where + i
        if @lines[ where + i ][0..this.size-1] == this
          next if @lines_size -1 < where + i + counter
          while @lines[ where + i + counter ][0..that.size-1] != that do
            if @lines[ where + i + counter ] == 'x'
              if @lines[ where + i + counter + 1 ] ==  "Egyéb (nevezze meg):"
                lin = @lines[ where + i + counter + 2 ]
              else
                lin = @lines[ where + i + counter + 1 ]
              end
              result << lin
            end
            counter += 1
            break if counter > LMAX or @lines_size -1 < where + i + counter
          end
          return result
        end
      end
    end

    def look_x_after_between( this, that, where )
      result  = []
      counter = 1
      for i in 1..LMAX do 
        next if @lines_size -1 < where + i
        #        puts "scanning... #{where + i} ::: #{@lines[where + i]}"
        if @lines[ where + i ][0..this.size-1] == this
          #          puts "benn: #{where + i} ::: #{@lines[where + i]}"
          while @lines[ where + i + counter ][0..that.size-1] != that do
            #            puts "alatta: #{ where + i + counter} ::: #{@lines[where + i + counter]}"
            if @lines[ where + i + counter ] == 'x'
              #              puts "iksz: #{ where + i + counter -1} ::: #{@lines[where + i + counter -1]}"
              if @lines[ where + i + counter - 1 ] == "Egyéb (nevezze meg):"
                lin = @lines[ where + i + counter + 1 ]
              else
                lin = @lines[ where + i + counter - 1 ]
              end
              result << lin 
            end
            counter += 1
            break if counter > LMAX or @lines_size -1 < where + i + counter
          end
          return result
        end
      end
    end

    def look_cpv_between( this, that, where )
      result  = []
      counter = 1
      for i in 1..LMAX do 
        next if @lines_size -1 < where + i
        if @lines[ where + i ][0..this.size-1] == this
          next if @lines_size -1 < where + i + counter
          while @lines[ where + i + counter ][0..that.size-1] != that do
            if @lines[ where + i + counter ].match(/\d{8,8}/)
              result << @lines[ where + i + counter ]
            end
            counter += 1
            break if counter > LMAX or @lines_size -1 < where + i + counter
          end
          return result
        end
      end
    end

    def maxnumber s
      # van ilyen is: "4 248 190 4.248.190"   
      minta = s.match(/\d{1,3}\.\d{3,3}\.\d{3,3}\.\d{3,3}/)
      if minta and minta.to_s.scan(/\d/).join == s.match(/\d{1,3} \d{3,3} \d{3,3} \d{3,3}/).to_s.scan(/\d/).join
        return minta.to_s.scan(/\d/).join.to_i
      end
      minta = s.match(/\d{1,3}\.\d{3,3}\.\d{3,3}/)
      if minta and minta.to_s.scan(/\d/).join == s.match(/\d{1,3} \d{3,3} \d{3,3}/).to_s.scan(/\d/).join
        return minta.to_s.scan(/\d/).join.to_i
      end
      minta = s.match(/\d{1,3}\.\d{3,3}/)
      if minta and minta.to_s.scan(/\d/).join == s.match(/\d{1,3} \d{3,3}/).to_s.scan(/\d/).join
        return s.match(/\d{1,3}\.\d{3,3}/).to_s.scan(/\d/).join.to_i
      end
      # egyébként felszabdaljuk rsézeekre és kiszedjük a vessző welőtti (az lesz a nagyobb) számot
      summa = 0
      s.split(/\d+\.rész/).each do |b|
        b.split(/\d+\. rész/).each do |c|
          c.split('rész').each do |d|     # van amikor római számmal írják
            t = []
            # ilyen is van: "24,187,000.-"
            minta = d.match(/\d{1,3},\d{3,3},\d{3,3},\d{3,3}/).to_s
            if minta.present?
              d.gsub!( minta, minta.gsub(',','x')) # valami másra, lényeg, hogy ne pontra, mert azt most visszavesszőzzuk:
              d.gsub!( '.', ',')
            end
            minta = d.match(/\d{1,3},\d{3,3},\d{3,3}/).to_s
            if minta.present?
              d.gsub!( minta, minta.gsub(',','x')) # valami másra, lényeg, hogy ne pontra, mert azt most visszavesszőzzuk:
              d.gsub!( '.', ',')
            end
            minta = d.match(/\d{4},\d{2}/)
            if minta.present?
              d = d.split( minta.to_s )[0] + minta.to_s.split(',')[0]
            end
            minta = d.match(/\d{1,3},\d{3,3}/).to_s
            if minta.present? and !d.match(/\.\d{3,3},\d{3,3}/)
              d.gsub!( minta, minta.gsub(',','x')) # valami másra, lényeg, hogy ne pontra, mert azt most visszavesszőzzuk:
              d.gsub!( '.', ',')
            end
            # végül kivesszük a számokat belőle
            d.split(',').each do |e|
              t << e.scan(/[0-9]/).join.to_i
            end
            summa = summa + t.max
          end
        end
      end
      return summa
    end

    def look_price_between( this, that, where )
      result = {}
      number = nil
      currency = ''
      counter = 1
      for i in 1..LMAX do 
        next if @lines_size -1 < where + i
        if @lines[ where + i ][0..this.size-1] == this
          next if @lines_size -1 < where + i + counter
          while @lines[ where + i + counter ][0..that.size-1] != that do
            if @lines[ where + i + counter ] == "Érték (arab számmal)"
              current_line = @lines[ where + i + counter + 1]
              number = maxnumber( current_line.split('/')[0] )
            end
            if @lines[ where + i + counter ] == "Pénznem"
              currency = @lines[ where + i + counter + 1].scan(/[a-zA-Z]/).join.upcase
              currency = "HUF" if currency[0..5] == "FORINT"
              currency = "N/A" if currency == "FANLKL"  # áfa nélkül
              currency = "N/A" if currency == "FVL"     # áfával
            end
            counter += 1
            break if counter > LMAX
          end
          result[:value] = number.to_i
          result[:currency] = currency
          result[:original] = current_line
          return result
        end
      end
    end

    def commify(v) 
      (s=v.to_s;x=s.length;s).rjust(x+(3-(x%3))).scan(/.{3}/).join(',').strip
    end

    def afa(this)
      if this == ["ÁFA nélkül"] 
        false 
      elsif this == ["ÁFÁ-val"]
        true
      else
        nil
      end
    end

    # initioalize
    info = InformationSource.find_or_create_by_name("Közbeszerzési Értesítő") do |r|
      r.name = "Közbeszerzési Értesítő"
      r.web = "http://www.kozbeszerzes.hu"
    end
    user = User.find_or_create_by_name("Beta") do |u|
      u.name = "Beta"
      u.email_address = "beta@addig.hu"
    end


    # reading data...
    # for lapid in 326000..326230 do
    # for lapid in 325000..325999 do
    # for lapid in 324000..324999 do 
    # for lapid in 323000..323999 do 
    # for lapid in 320000..320999 do 
    # for lapid in 321000..322999 do 
    # for lapid in 319000..319999 do - in progress
    # old - 319025, 319055,
    # for lapid in 319020..319999 do 
    #
    # 32

#    for lapid in 319220..319999 do 
#    for lapid in 319422..328837 do 
    Notification.all.each do |note|
      lapid = note.number
      puts lapid
      @lines = []
      # ha még nincs meg ez az értesítő
      # note = Notification.find_by_number(lapid.to_s) 
      if note
        # ha van tempfile, használjuk azt
        if !File.exist?(Rails.root + "db/kbe/#{lapid}.pdf") or File.stat(Rails.root + "db/kbe/#{lapid}.pdf").size == 0
          puts "skipping #{Rails.root.to_s}/db/kbe/#{ lapid }.pdf, no file found or file is empty..."
          next
        end
        puts "parsing data from #{Rails.root.to_s}/db/kbe/#{ lapid }.pdf, please wait..."
        pdf = PdfFilePath.new(Rails.root.to_s + "/db/kbe/#{ lapid }.pdf")
        xml = pdf.convert_to_xml
        puts "preparing..."
        # parsing starts here
        file = File.new( Rails.root.to_s + "/db/kbe/#{lapid}.txt", 'w' )
        xml.each_line do |line|
          if line[0..9] == '<text top='
            @lines << Nokogiri::HTML(line).text.strip
            file.write( Nokogiri::HTML(line).text )
            file.write "\n"
          end
        end
        file.close
      else
        puts "Skipping: notification not found in the  database..."
        next
      end

      puts @lines_size = @lines.size

      if File.exist?("db/kbe/#{lapid}.nfo")
        nfo = File.open("db/kbe/#{lapid}.nfo")
        name = nfo.read.strip
        nfo.close
      else
        name = look_between("a Közbeszerzések Tanácsa Hivatalos Lapja", "--", 1)
        if name.kind_of?(Range)
          puts filepath
          name = filepath.split("KE-").last.split(".pdf").first
        else
          name = name.strip
        end
        nfo = File.open("db/kbe/#{lapid}.nfo", 'w')
        nfo.puts(name)
        nfo.close
      end

# note megvan, most meg kell keresni a contract-ot az ügyiratszám alapján és arról leszedni a teljesítés heléyz aztán beírni a db-be

      @sum = 0
      @sums = []
      @ertekek = []
      @lines.each_with_index do |v, i|
        if v == "tájékoztató"
          if @lines[i + 1] == "az eljárás eredményéről"
            puts '======================================='
            puts case_number = @lines[i - 6].split(" ").last.try[1..-2]

            puts ":: teljesítés helye"
            puts c_telj_helye = look("A teljesítés helye", i)

            con = Contract.find_by_case_number( case_number )
            if con
              con.update_attribute :place_of_performance, c_telj_helye
            else
              puts "contract not found by case number #{ case_number}"
            end

          end
        end
      end
    end
  end


  desc 'fetch people'
  task :people => :environment do
    i = Person.count
    people = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/szemelyek'))
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    people.css(".tags_table a").each do |person|
      name = person.children[0].text.split(' ')
      last_name = name[0]
      first_name= name[1..-1].join(' ') if name.length>1
      pe = Person.find_by_first_name_and_last_name(first_name, last_name)
      if !pe && first_name!=nil
        puts "saving person: " +  person.children[0].text
        Person.create!(:last_name => last_name, :first_name => first_name, :klink => '/' + person.attributes['href'].value, :information_source_id => info_id)
      elsif !first_name
        puts "Couldn't fetch person: #{last_name}, #{person.attributes['href'].value}"
      end
    end
    puts (Person.count - i).to_s + " people added"
  end

  desc 'fetch organizations'
  task :organizations => :environment do
    i = Organization.count
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    grade_id = OrgGrade.find_by_name("magáncég").id
    organizations = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/intezmenyek'))
    organizations.css(".tags_table a").each do |organization|
      org = Organization.find_by_name(organization.children[0].text)
      if !org
        puts "saving organization: " +  organization.children[0].text
        orge = Organization.create(:name  => organization.children[0].text, :klink => '/' + organization.attributes['href'].value, :information_source_id => info_id, :org_grade_id => grade_id)
      end
    end
    puts (Organization.count - i).to_s + " organization added"
  end

  desc 'fetch article dates'
  task :dates => :environment do
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    f_p2p = P2pRelationType.find_by_name('sajtó')
    f_o2o = O2oRelationType.find_by_name('sajtó')
    f_o2p = O2pRelationType.find_by_name('sajtó')
    f_p2o = P2oRelationType.find_by_name('sajtó')
    articles = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/kereses'))
#    (1..articles.css("span.result")[0].children[0].text.to_i / 10 + 1).each do |i|
    (1..156).each do |i|
      puts "fetching page #{i} on k-monitor.hu at " + Time.now.to_s
      articles = Nokogiri::HTML(open("http://www.k-monitor.hu/kereses?page=#{i}"))
      articles.css(".news_list_1").each do |article|
        if article.search("input[@name='halora']").first.attributes['value'].value == "igen"
          wlink = article.css("h3 a")[0].attributes['href'].value.split('?')[0] || ""
          issue_date = article.css(".extra a")[1].text.to_textual_id.to_date
          puts internet_address = "http://www.k-monitor.hu/" + wlink
          a = Article.find_by_internet_address(internet_address) 
          if a 
            puts a.issued_at = issue_date
            a.save
          end
        end
      end
    end
  end
          
   
  desc 'fetch article'
  task :articles => :environment do
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    f_p2p = P2pRelationType.find_by_name('sajtó')
    f_o2o = O2oRelationType.find_by_name('sajtó')
    f_o2p = O2pRelationType.find_by_name('sajtó')
    f_p2o = P2oRelationType.find_by_name('sajtó')
    articles = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/kereses'))
#    (1..articles.css("span.result")[0].children[0].text.to_i / 10 + 1).each do |i|
    (1..10).each do |i|
      puts "fetching page #{i} on k-monitor.hu at " + Time.now.to_s
      articles = Nokogiri::HTML(open("http://www.k-monitor.hu/kereses?page=#{i}"))
      articles.css(".news_list_1").each do |article|
        if article.search("input[@name='halora']").first.attributes['value'].value == "igen"
          wlink = article.css("h3 a")[0].attributes['href'].value.split('?')[0] || ""
          issue_date = article.css(".extra a")[1].text.gsub('május', 'may').gsub('szept','sept').gsub('okt','oct').to_textual_id.to_date
          puts internet_address = "http://www.k-monitor.hu/" + wlink
          a = Article.find_or_create_by_internet_address(internet_address) do |r|
            r.summary = article.css(".n_teaser")[0].children[0].text.strip
            r.name = article.css("h3 a")[0].children[0].text.strip
            r.weblink = wlink
            r.issued_at = issue_date
            r.internet_address = internet_address
          end
          puts a.issued_at = issue_date
          a.save
          tags = []
          article.css(".links a, .links_starred a").each do |link|
            href = link.attributes['href'].value.sub("/kereses","").split('?')[0]
            tag = Person.find_by_klink('/' + href) || Organization.find_by_klink('/' + href) || Person.find_by_klink(href) || Organization.find_by_klink(href)

            next unless tag
            tags << tag
          end
          tags.each do |t1|
            tags.each do |t2|
              if t1.klink != t2.klink
                if t1.kind_of?(Person) and t2.kind_of?(Person)
                  relation = InterpersonalRelation.find( :first, :conditions => [ 'person_id = ? and related_person_id = ? and information_source_id = ?', t1.id, t2.id, info_id ])
                  unless relation
                    relation = InterpersonalRelation.create!( :person_id => t1.id, 
                                                              :related_person_id => t2.id,
                                                              :information_source_id => info_id,
                                                              :p2p_relation_type_id => f_p2p.id,
                                                              :start_time => issue_date,
                                                              :no_end_time => true,
                                                              :parsed => true
                                                            )
                    puts "new relation for #{t1.name} and #{t2.name}"
                  else
                    relation.start_time = issue_date
                    relation.no_end_time = true
                    relation.save
                  end
                  unless relation.articles.include?(a)
                    relation.articles << a
                  end
                end
                
                if t1.kind_of?(Organization) and t2.kind_of?(Organization)
                  relation = InterorgRelation.find( :first, :conditions => [ 'organization_id = ? and related_organization_id = ? and information_source_id = ?', t1.id, t2.id, info_id])
                  unless relation
                    relation = InterorgRelation.create!( :organization_id => t1.id, :related_organization_id => t2.id, :information_source_id => info_id, :o2o_relation_type_id => f_o2o.id, :issued_at => issue_date, :parsed => true )
                    puts "new relation for #{t1.name} and #{t2.name}"
                  else
                    relation.issued_at = issue_date
                    relation.save
                  end
                  unless relation.articles.include?(a)
                    relation.articles << a
                  end
                end
                if t1.kind_of?(Person) and t2.kind_of?(Organization)
                  relation = PersonToOrgRelation.find( :first, :conditions => [ 'person_id = ? and organization_id = ? and information_source_id = ?', t1.id, t2.id, info_id])
                  unless relation
                    relation = PersonToOrgRelation.create!( :person_id => t1.id, 
                                                            :organization_id => t2.id,
                                                            :information_source_id => info_id,
                                                            :p2o_relation_type_id => f_p2o.id,
                                                            :start_time => issue_date,
                                                            :no_end_time => true,
                                                            :parsed => true
                                                          )
                    puts "new relation for #{t1.name} and #{t2.name}"
                  else
                    relation.start_time = issue_date 
                    relation.no_end_time = true 
                    relation.save
                  end
                  unless relation.articles.include?(a)
                    relation.articles << a
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
