require 'nokogiri'
require 'open-uri'

namespace :fetch do
  desc 'fetch ertesito'
  task :ertesito => :environment do

    require 'pdftohtmlr'
    include PDFToHTMLR
    lapid = 326224
#    ertesito = Nokogiri::HTML(open("http://www.kozbeszerzes.hu/lid/ertesito/pid/0/ertesitoProperties?objectID=Lapszam.portal_#{ lapid }"))
#    dl =  Nokogiri::HTML(open('http://www.kozbeszerzes.hu/' + ertesito.css('a.attach').last['href']))    
#    dl.css('a').last['href']
#    a = "085" # dl.css('a').last['href'].split('/').last.match(/\d+/).to_s
#    filepath = dl.css('a').last['href'].split('/')[0..-2].join('/') + "/KÉ%20#{a}%20teljes_alairt.pdf.pdf"
#    system "cd #{Rails.root + 'tmp'} && wget -O #{lapid}.pdf #{filepath}"
    puts "prepare..."
    puts Rails.root.to_s + "/tmp/#{ lapid }.pdf"
    pdf = PdfFilePath.new(Rails.root.to_s + "/tmp/#{ lapid }.pdf")
    xml = pdf.convert_to_xml
    LMAX = 2000
    @lines = []
    def look( what, where )
      for i in 1..LMAX do 
        if @lines[ where + i ] == what
          return @lines[ where + i + 1 ]
        end
      end
    end
    
    def look_between( this, that, where )
      result = ''
      counter = 1
      for i in 1..LMAX do 
        if @lines[ where + i ] == this
          while @lines[ where + i + counter] != that do
            result << @lines[ where + i + counter]
            result << "\n"
            counter += 1
          end
          return result
        end
      end
    end

    def look_x_before_between( this, that, where )
      result  = []
      counter = 1
      for i in 1..LMAX do 
        if @lines[ where + i ][0..this.size-1] == this
          while @lines[ where + i + counter ][0..that.size-1] != that do
            if @lines[ where + i + counter ] == 'x'
              result << @lines[ where + i + counter + 1 ]
            end
            counter += 1
            break if counter > LMAX
          end
          return result
        end
      end
    end

    def look_x_after_between( this, that, where )
      result  = []
      counter = 1
      for i in 1..LMAX do 
#        puts "scanning... #{where + i} ::: #{@lines[where + i]}"
        if @lines[ where + i ][0..this.size-1] == this
#          puts "benn: #{where + i} ::: #{@lines[where + i]}"
          while @lines[ where + i + counter ][0..that.size-1] != that do
#            puts "alatta: #{ where + i + counter} ::: #{@lines[where + i + counter]}"
            if @lines[ where + i + counter ] == 'x'
#              puts "iksz: #{ where + i + counter -1} ::: #{@lines[where + i + counter -1]}"
              result << @lines[ where + i + counter - 1 ]
            end
            counter += 1
            break if counter > LMAX
          end
          return result
        end
      end
    end

    file = File.new( Rails.root.to_s + "/tmp/#{lapid}.xml", 'w' )
    xml.each_line do |line|
      if line[0..9] == '<text top='
        @lines << Nokogiri::HTML(line).text.strip
        file.write( Nokogiri::HTML(line).text )
        file.write "\n"
      end
    end
    @lines.each_with_index do |v, i|
      if v == "tájékoztató"
        if @lines[i + 1] == "az eljárás eredményéről"
          puts '======================================='
          puts @lines[i + 8]
          puts '======================================='
          puts look("Hivatalos név:", i)
          puts look("Postai cím:", i)
          puts look("Város/Község:", i)
          puts look("Postai irányítószám:", i)
          puts look("Telefon:", i)
          puts look("E-mail:", i)
          puts look("Fax:",    i)
          puts look("Az ajánlatkérő általános címe (URL):", i)
          # az ajánlatkérő típusa
          puts look_x_after_between(  "I.2.) Az ajánlatkérő típusa",
                                      "I.3", i).inspect
          # az ajánlatkérő tevékenységi köre
          puts look_x_before_between( "I.3",
                                      "Az ajánlatkérő más ajánlatkérők nevében folytatja-e le a közbeszerzési eljárást?", i).inspect
          puts "::ELNEVEZÉS"
          puts look_between("II.1.1) Az ajánlatkérő által a szerződéshez rendelt elnevezés",
                            "II.1.2) A szerződés típusa, valamint a teljesítés helye ( Csak azt a kategóriát válassza – építési beruházás,", i)
          puts "::TÁRGY, MENNYISÉG"
         puts look_between("II.1.5) A szerződés vagy a közbeszerzés(ek) tárgya, mennyisége",
                            "II.1.6) Közös Közbeszerzési Szójegyzék (CPV)", i)

        
        
        
        
        end
      end
    end
    file.close
    puts 'lofa'
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

  desc 'fetch article'
  task :articles => :environment do
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    f_p2p = P2pRelationType.find_by_name('közös sajtó')
    f_o2o = O2oRelationType.find_by_name('közös sajtó')
    f_o2p = O2pRelationType.find_by_name('közös sajtó')
    f_p2o = P2oRelationType.find_by_name('közös sajtó')
    articles = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/kereses'))
#    (1..articles.css("span.result")[0].children[0].text.to_i / 10 + 1).each do |i|
    (1..4).each do |i|
      puts "fetching page #{i} on k-monitor.hu at " + Time.now.to_s
      articles = Nokogiri::HTML(open("http://www.k-monitor.hu/adatbazis/kereses?page=#{i}"))
      articles.css(".news_list_1").each do |article|
        wlink = article.css("h3 a")[0].attributes['href'].value.split('?')[0] || ""
        internet_address = "http://www.k-monitor.hu/" + wlink
        a = Article.find_or_create_by_internet_address(internet_address) do |r|
          r.summary = article.css(".n_teaser")[0].children[0].text
          r.title = article.css("h3 a")[0].children[0].text
          r.weblink = wlink 
          r.internet_address = internet_address
        end
        tags = []
        article.css(".links a, .links_starred a").each do |link|
          href = link.attributes['href'].value.sub("/kereses","").split('?')[0]
          tag = Person.find_by_klink(href) || Organization.find_by_klink(href)
          next unless tag
          tags << tag
        end
        tags.each do |t1|
          tags.each do |t2|
            if t1.klink != t2.klink
              if t1.kind_of?(Person) and t2.kind_of?(Person)
                relation = InterpersonalRelation.find( :first, :conditions => [ 'person_id = ? and related_person_id = ? and information_source_id = ?', t1.id, t2.id, info_id ])
                unless relation
                  relation = InterpersonalRelation.create( :person_id => t1.id, :related_person_id => t2.id, :information_source_id => info_id, :p2p_relation_type_id => f_p2p.id )
                end
                unless relation.articles.include?(a)
                  relation.articles << a
                end
              end
              
              if t1.kind_of?(Organization) and t2.kind_of?(Organization)
                relation = InterorgRelation.find( :first, :conditions => [ 'organization_id = ? and related_organization_id = ? and information_source_id = ?', t1.id, t2.id, info_id])
                unless relation
                  relation = InterorgRelation.create!( :organization_id => t1.id, :related_organization_id => t2.id, :information_source_id => info_id, :o2o_relation_type_id => f_o2o.id)
                end
                unless relation.articles.include?(a)
                  relation.articles << a
                end
              end
              if t1.kind_of?(Person) and t2.kind_of?(Organization)
                relation = PersonToOrgRelation.find( :first, :conditions => [ 'person_id = ? and organization_id = ? and information_source_id = ?', t1.id, t2.id, info_id])
                unless relation
                  relation = PersonToOrgRelation.create!( :person_id => t1.id, :organization_id => t2.id, :information_source_id => info_id, :p2o_relation_type_id => f_p2o.id)
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
