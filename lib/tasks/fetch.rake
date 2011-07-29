require 'nokogiri'
require 'open-uri'

namespace :fetch do
  desc 'fetch ertesito'
  task :ertesito => :environment do

    require 'pdftohtmlr'
    include PDFToHTMLR
    lapid = 326224
    info = InformationSource.find_or_create_by_name("Közbeszerzési Értesítő") do |r|
      r.name = "Közbeszerzési Értesítő"
      r.web = "http://www.kozbeszerzes.hu"
    end
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
    LMAX = 4000
    @lines = []

    def get_pos( what, where )
      for i in 1..(LMAX*3) do 
        if @lines[ where + i ][0..what.size-1] == what
          return where + i
        end
      end
      nil
    end

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
              if @lines[ where + i + counter + 1 ] ==  "Egyéb (nevezze meg):"
                lin = @lines[ where + i + counter + 2 ]
              else
                lin = @lines[ where + i + counter + 1 ]
              end
              result << lin
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
              if @lines[ where + i + counter - 1 ] == "Egyéb (nevezze meg):"
                lin = @lines[ where + i + counter + 1 ]
              else
                lin = @lines[ where + i + counter - 1 ]
              end
              result << lin 
            end
            counter += 1
            break if counter > LMAX
          end
          return result
        end
      end
    end

    def look_cpv_between( this, that, where )
      result  = []
      counter = 1
      for i in 1..LMAX do 
        if @lines[ where + i ][0..this.size-1] == this
          while @lines[ where + i + counter ][0..that.size-1] != that do
            if @lines[ where + i + counter ].match(/\d{8,8}/)
              result << @lines[ where + i + counter ]
            end
            counter += 1
            break if counter > LMAX
          end
          return result
        end
      end
    end

    def look_price_between( this, that, where )
      result = {}
      number = nil
      currency = ''
      counter = 1
      for i in 1..LMAX do 
        if @lines[ where + i ][0..this.size-1] == this
          while @lines[ where + i + counter ][0..that.size-1] != that do
            if @lines[ where + i + counter ] == "Érték (arab számmal)"
              number = @lines[ where + i + counter + 1].scan(/[0-9]/).join.to_i
            end
            if @lines[ where + i + counter ] == "Pénznem"
              currency = @lines[ where + i + counter + 1]
            end
            counter += 1
            break if counter > LMAX
          end
          if number
            result[currency] = number
          end
          return result
        end
      end
    end

    def commify(v) 
      (s=v.to_s;x=s.length;s).rjust(x+(3-(x%3))).scan(/.{3}/).join(',').strip
    end
 
    def afa(this)
      this == "ÁFA nélkül" ? false : true
    end

    # parsing starts here
    file = File.new( Rails.root.to_s + "/tmp/#{lapid}.xml", 'w' )
    xml.each_line do |line|
      if line[0..9] == '<text top='
        @lines << Nokogiri::HTML(line).text.strip
        file.write( Nokogiri::HTML(line).text )
        file.write "\n"
      end
    end

    name = look("a Közbeszerzések Tanácsa Hivatalos Lapja")

    if !Notification.find_by_name(name)

      date = name[-11..-1].to_date
      note = Notification.create!( :name => name, :issued_at => date,  :number => lapid )

      @sum = 0
      @sums = []
      @ertekek = []
      @lines.each_with_index do |v, i|
        if v == "tájékoztató"
          if @lines[i + 1] == "az eljárás eredményéről"
            puts '======================================='
            puts @lines[i + 8]
            puts '======================================='
            puts megrendelo = look_between("Hivatalos név:", "Postai cím:", i).split("\n").join(' ')

            puts m_cim = look("Postai cím:", i)
            puts m_varos = look("Város/Község:", i)
            puts m_irszam = look("Postai irányítószám:", i)
            puts m_telefon = look("Telefon:", i)
            puts m_email = look("E-mail:", i)
            puts m_fax = look("Fax:",    i)
            puts m_url = look("Az ajánlatkérő általános címe (URL):", i)
            # az ajánlatkérő típusa
            puts m_tipus = look_x_after_between(  "I.2.) Az ajánlatkérő típusa",
                                                  "I.3", i)
            # az ajánlatkérő tevékenységi köre
            puts m_tevekenyseg = a = look_x_before_between( "I.3",
                                           "Az ajánlatkérő más ajánlatkérők nevében folytatja-e le a közbeszerzési eljárást?", i).inspect

            puts ":: ELNEVEZÉS"
            puts c_elnevezes = look_between("II.1.1) Az ajánlatkérő által a szerződéshez rendelt elnevezés",
                              "II.1.2) A szerződés típusa, valamint a teljesítés helye ( Csak azt a kategóriát válassza – építési beruházás,", i)
            puts ":: TÁRGY, MENNYISÉG"
            puts targy1 = look_between("II.1.4) A szerződés vagy a közbeszerzés(ek) tárgya, mennyisége",
                              "II.1.5) Közös Közbeszerzési Szójegyzék (CPV)", i)
            puts targy2 = look_between("II.1.5) A szerződés vagy a közbeszerzés(ek) tárgya, mennyisége",
                              "II.1.6) Közös Közbeszerzési Szójegyzék (CPV)", i)
            puts c_targy = targy1.class == Range ? targy2 : targy1

            puts ":: szerődés tipusa"
            puts c_tipus = look_x_before_between("II.1.2) A szerződés típusa, valamint a teljesítés helye", "II.1.3)", i).inspect

            puts ":: keretszerződés v dbr?"
            # keretszerzodés?
            puts keret1 = look_x_after_between("II.1.2) A hirdetmény a következők valamelyikével kapcsolatos",
                                      "II.1.4)", i)
            puts keret2 = look_x_after_between("II.1.3) A hirdetmény a következők valamelyikével kapcsolatos",
                                      "II.1.5)", i)

            puts c_keret = keret1.class == Range ? keret2 : keret1



            puts ":: milyen a keretmegállapodás"
            puts look_x_after_between("III.1.3) A keretmegállapodás megkötésére milyen eljárás alkalmazásával került sor?",
                                      "III.2)", i)


            puts ":: CPV"
            # kétféle is lehet:
            puts cpv1 = look_cpv_between("II.1.5) Közös Közbeszerzési Szójegyzék (CPV)", "II.2) A szerződés(ek) értéke", i)
            puts cpv2 = look_cpv_between("II.1.6) Közös Közbeszerzési Szójegyzék (CPV)", "II.2) A szerződés(ek) értéke", i)
            puts c_cpv = cpv1.class == Range ? cpv2 : cpv1


            puts ":: ÉRTÉK"
            # érták
            h = look_price_between("II.2) A szerződés(ek) értéke", 
                                   "III.1.1)", i)


            puts ":: ÁFA"
            # áfa info:

            look_x_after_between("II.2) A szerződés(ek) értéke", "III.1.1)", i)

            c_currency = h.keys.first
            c_sum_value = h[ h.keys.first ]
            puts h.inspect
            puts commify( h[h.keys.first] )
            # az aktuális hirdetmény vége
            puts v = get_pos("E hirdetmény feladásának dátuma", i)

            # nézzük, kikkel szerződtek

            j = get_pos("IV. szakasz", i)

            while j and j < v do

              puts c_number = look("A Szerződés száma", j)
              puts c_name = look_between("Megnevezése", "IV.1)", j)
              puts c_contracting_at = look("A szerződéskötés tervezett időpontja", j).to_date
              puts c_no_of_other_proposals = look("A benyújtott ajánlatok száma", j).to_i
              puts vallalkozo = look_between("Hivatalos név:", "Postai cím:", j).split("\n").join(' ')
              puts c_cim = look("Postai cím:", j)
              puts c_varos = look("Város/Község:", j)
              puts c_irszam = look("Postai irányítószám:", j)
              puts c_telefon = look("Telefon:", j)
              puts c_email = look("E-mail:", j)
              puts c_fax = look("Fax:",    j)

              a = look("Internetcím (URL):", j)
              if a != "IV.4) A szerződés értékére vonatkozó információ (csak számokkal)"
                puts c_url = a
              end

              puts ":: eredetileg becsült érték"
              # bscsüét érték 
              h = look_price_between("Az ellenszolgáltatás eredetileg becsült értéke", 
                                     "Az ellenszolgáltatás szerződésbeli összege", j)

              puts ":: ÁFA"
              # áfa info:
              puts c_becsult_afa = look_x_after_between("Az ellenszolgáltatás eredetileg becsült értéke",
                                                        "Az ellenszolgáltatás szerződésbeli összege", j)
              puts h.inspect
              puts commify( h[h.keys.first] )
              puts c_becsult = h[h.keys.first]


              puts ":: Az ellenszolgáltatás szerződésbeli összege"

              # szerződéses összeg 
              h = look_price_between( "Az ellenszolgáltatás szerződésbeli összege", 
                                     "a legalacsonyabb ellenszolgáltatást tartalmazó ajánlat", j)

              puts ":: ÁFA"
              # áfa info:
              puts afa = look_x_after_between( "Az ellenszolgáltatás szerződésbeli összege",
                                              "a legalacsonyabb ellenszolgáltatást tartalmazó ajánlat", j)
              puts h.inspect
              puts commify( h[h.keys.first] )
              puts c_ertek = h[h.keys.first]

              @sum = @sum + h[h.keys.first]
              @sums << commify( h[h.keys.first] )

              e = look("V.2.2) Ha az eljárás eredménytelen, illetve szerződéskötésre nem kerül sor, ennek indoka", j)

              if e != "V.2.3) A nyertes ajánlattevőnek a közbeszerzési törvény 70. §-ának (2) bekezdése szerinti minősítése"
                eredmenytelen = true
              else
                eredmenytelen = false
              end

              break if c_ertek == 0 and eredmenytelen

              @ertekek << [ h.keys.first, commify( h[ h.keys.first ] ), megrendelo, vallalkozo, afa,  h[ h.keys.first ]  ]

              if vallalkozo[-4..-1] == ' Kft' or
                vallalkozo[-3..-1] == ' Rt' or
                vallalkozo[-3..-1] == ' Bt' or
                vallalkozo[-4..-1] == ' Zrt' or
                vallalkozo[-5..-1] == ' Nyrt'

                vallalkozo = vallalkozo + '.'
              end

              vall = Organization.find_by_name(vallalkozo)
              if !vall
                vall = Organization.create!( :name => vallalkozo,
                                             :street => c_cim,
                                             :city => c_varos,
                                             :zip_code => c_irszam,
                                             :phone => c_telefon,
                                             :fax => c_fax,
                                             :email_address => c_email,
                                             :internet_address => c_url
                                           )
              end
              megr = Organization.find_by_name(megrendelo)
              if !megr
                megr = Organization.create!( :name => megrendelo,
                                             :street => m_cim,
                                             :city => m_varos,
                                             :zip_code => m_irszam,
                                             :phone => m_telefon,
                                             :fax => m_fax,
                                             :email_address => m_email,
                                             :internet_address => m_url
                                           ) 

                                             
              end

              contract = Contract.create!( :number => c_number,
                                :name => c_name,
                                :contracting_at => c_contracting_at.to_date,
                                :no_of_other_proposals => c_no_of_other_proposals.to_i,
                                :buyer_id => megr.id,
                                :seller_id => vall.id,
                                :description => c_elnevezes,
                                :subject_and_qty => c_targy,
                                :sum_value => c_sum__value,
                                :s_vat_incl =>,
                                :contracted_value c_ertek,
                                :c_vat_incl =>,
                                :estimated_value => c_becsult,
                                :e_vat_incl => ,
                                :currency => m_currency
                              )

              InterorgRelation.create( :value => c_ertek,
                                       :currency => c_currency,
                                       :vat_incl => afa(c_ertek_afa),
                                       :contract_id = contract.id,
                                       :o2o_relation_type_id = O2oRelationType.find_by_name("Közbeszerző").id,
                                       :organization_id => megr.id,
                                       :related_organization_id => vall.id,
                                       :information_source_id => info.id
                                     )

              puts ":: a legalacsonyabb vagy mi..."
              # legalacsonyabb 
              h = look_price_between("a legalacsonyabb ellenszolgáltatást tartalmazó ajánlat", "Valószínűsíthető", j)

              puts ":: ÁFA"
              # áfa info:
              look_x_after_between( "a legalacsonyabb ellenszolgáltatást tartalmazó ajánlat", "Valószínűsíthető", j)
              puts h.inspect
              puts commify( h[h.keys.first] )

              # ugrás a következő vállalkozóra ebben a hirdetményben
              j = get_pos("IV. szakasz", j)

            end    



          end
        end
      end
      file.close
      puts '=========== összesen ============'
      puts commify( @sum )
      @ertekek.sort {|x,y| y[5] <=> x[5] }.each do |e| puts e.inspect end
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
