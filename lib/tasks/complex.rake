namespace :complex do

  desc 'split complex xml file to ceg xmls'
  task :slice => :environment do
    f = File.open('db/complex/data.xml', 'r')
    encoding = f.gets.strip
    if f.gets.strip == "<export>"
      f.each do |l|
        if l[0..7] == "<ceg id="
          puts @o = File.open("db/complex/orgs/#{l.strip.scan(/\d+/).first.to_i}.xml", "w")
        end
        if l[0..7] == "</ceg>"
          @o.close
          next
        end
        break if l == "</export>"
        @o.puts(l)
      end
    end
    f.close
  end

  desc "import each file info the database"
  task :import => :environment do

    # initialize
    @info = InformationSource.find_or_create_by_name("MVH") do |r| 
      r.name = "Complex"
      r.web = "http://www.complex.hu"
    end
    user = User.find_or_create_by_name("Beta") do |u|
      u.name = "Beta" 
      u.email_address = "beta@addig.hu"
    end

    def to_tax_nr s
      "#{s[0..7]}-#{s[8..8]}-#{s[9..10]}"
    end

    def to_date a
      if a.blank?
        return nil
      else
        a.to_date
      end
    rescue
      return nil
    end


    def role_to_relation_type role, pair, klass, subrole=nil
      if subrole
        i = P2pRelationType.find_or_create_by_name_and_internal( subrole, true ) do |r|
          r.name = subrole
          r.internal = true
        end
        a = P2oRelationType.find_or_create_by_name_and_parsed( role, true ) do |r|   
          r.name = role
          r.p2p_relation_type_id = i.id
          r.parsed = true
        end
        b = O2pRelationType.find_or_create_by_name_and_parsed( pair, true ) do |r|
          r.name = pair
          r.p2p_relation_type_id = i.id
          r.pair_id = a.id
          r.parsed = true
        end
        a.update_attribute :pair_id, b.id
        return a if klass == "P2oRelationType"
        return b if klass == "O2pRelationType"  # ilyenkor fordítva lesz!! ésszel :)
      else
        relation_type = klass.find_or_create_by_name(role) do |r|
          r.name = role
          r.pair = klass.create!( :name => pair, :parsed => true ) 
        end
        relation_type.pair.update_attribute :pair_id, relation_type.id 
        return relation_type
      end
    end

    def parse_member a, role, pair_role, subrole=nil

      puts ':: hatig:'
      puts hatig  = to_date(a.search('mezo[@id="hatig"]').text.strip)
      puts nev =    a.search('mezo[@id="nev"]').text.strip
      if nev.empty?   # akkor ez person lesz
        puts is_person = true
        puts pnev  =  a.search('mezo[@id="pnev"]').text.strip
        puts panev =  a.search('mezo[@id="panev"]').text.strip
        puts porsz = "Magyarország"
        puts pirsz =  a.search('mezo[@id="pirsz"]').text.strip
        puts phely =  a.search('mezo[@id="phely"]').text.strip
        puts pteru =  a.search('mezo[@id="pteru"]').text.strip
        puts phsz  =  a.search('mezo[@id="phsz"]').text.strip
        if phely.empty?
          puts porsz =  a.search('mezo[@id="pkorsz"]').text.strip
          puts pirsz =  a.search('mezo[@id="pkirsz"]').text.strip
          puts phely =  a.search('mezo[@id="pkhely"]').text.strip
          puts pteru =  a.search('mezo[@id="pkteru"]').text.strip
          puts phsz  =  a.search('mezo[@id="pkhsz"]').text.strip
        end
        # kézbesítési megbízott
        puts pmnev  =  a.search('mezo[@id="pmnev"]').text.strip
        puts pmanev =  a.search('mezo[@id="pmanev"]').text.strip
        puts pmorsz = "Magyarország"
        puts pmirsz =  a.search('mezo[@id="pmirsz"]').text.strip
        puts pmhely =  a.search('mezo[@id="pmhely"]').text.strip
        puts pmteru =  a.search('mezo[@id="pmteru"]').text.strip
        puts pmhsz  =  a.search('mezo[@id="pmhsz"]').text.strip
        if pmhely.empty? # akkor ő külföldi
          puts pmorsz =  a.search('mezo[@id="pmkorsz"]').text.strip
          puts pmirsz =  a.search('mezo[@id="pmkirsz"]').text.strip
          puts pmhely =  a.search('mezo[@id="pmkhely"]').text.strip
          puts pmteru =  a.search('mezo[@id="pmkteru"]').text.strip
          puts pmhsz  =  a.search('mezo[@id="pmkhsz"]').text.strip
        end
      else # amikor org
        puts is_person = false
        puts cgjsz  =  a.search('mezo[@id="cgjsz"]').text.strip  
        puts orszag =  a.search('mezo[@id="orsz"]').text.strip 
        puts irsz   =  a.search('mezo[@id="irsz"]').text.strip
        puts hely   =  a.search('mezo[@id="hely"]').text.strip
        puts teru   =  a.search('mezo[@id="teru"]').text.strip
        puts hsz    =  a.search('mezo[@id="hsz"]').text.strip
      end
      puts "tisztség"
      puts tiszt  =  a.search('mezo[@id="tiszt"]').text.strip
      puts email  =  a.search('mezo[@id="email"]').text.strip
      puts labjegyzet = a.search('mezo[@id="labj"]').text.strip
      puts adosz      = a.search('mezo[@id="adosz"]').text.strip
      puts adoazon    = a.search('mezo[@id="adoazon"]').text.strip
      puts "::egyutt:"
      puts kepve      = ( a.search('mezo[@id="kepve"]').text.strip == 'x' ? true : false )
      puts "::onalloan:"
      puts kepvo      = ( a.search('mezo[@id="kepvo"]').text.strip == 'x' ? true : false )
      puts tv         = a.search('mezo[@id="tv"]').text.strip

      puts "TV::::: begin"
      puts ':: jogvk:'
      puts jogvk    = to_date(a.search('mezo[@id="jogvk"]'  ).text.strip)
      puts ':: jogvv:'
      puts jogvv    = to_date(a.search('mezo[@id="jogvv"]'  ).text.strip)
      puts pcnev    = a.search('mezo[@id="pcnev"]'  ).text.strip
      puts pcanev   = a.search('mezo[@id="pcnanev"]').text.strip
      puts pccegj   = a.search('mezo[@id="pcnanev"]').text.strip
      puts pcirsz   = a.search('mezo[@id="pcirsz"]' ).text.strip
      puts pchely   = a.search('mezo[@id="pchely"]' ).text.strip
      puts pcteru   = a.search('mezo[@id="pcteru"]' ).text.strip
      puts pchsz    = a.search('mezo[@id="pchesz"]' ).text.strip
      puts pckorsz  = a.search('mezo[@id="pckorsz"]').text.strip
      puts pckirsz  = a.search('mezo[@id="pckirsz"]').text.strip
      puts pckhely  = a.search('mezo[@id="pckhely"]').text.strip
      puts pckteru  = a.search('mezo[@id="pckteru"]').text.strip
      puts pckhsz   = a.search('mezo[@id="pckhsz"]' ).text.strip
      puts mindig   = a.search('mezo[@id="mindig"]' ).text.strip
      puts mnev     = a.search('mezo[@id="mnevig"]' ).text.strip
      puts ':: valtk'
      puts valtk    = to_date(a.search('mezo[@id="valtk"]'  ).text.strip)
      puts ':: valtv:'
      puts valtv    = to_date(a.search('mezo[@id="valtv"]'  ).text.strip)
      puts tnytsz   = a.search('mezo[@id="knytsz"]' ).text.strip
      puts knytsz   = a.search('mezo[@id="tnytsz"]' ).text.strip
      puts knyh     = a.search('mezo[@id="knyh"]'   ).text.strip
      puts ':: bkelt:'
      puts bkelt    = to_date(a.search('mezo[@id="bkelt"]'  ).text.strip)
      puts ':: tkelt:'
      puts tkelt    = to_date(a.search('mezo[@id="tkelt"]'  ).text.strip)
      puts "TV::::: end"
      if is_person
        person = Person.find_by_name_and_mothers_name(pnev, panev)
        person = Person.find_by_name(pnev) unless person
        if person.nil?
          name = pnev.split(' ')
          last_name  = name[0]
          first_name = name[1..-1].join(' ') if name.length > 1
          person = Person.create!( :first_name => first_name,
                                 :last_name  => last_name,
                                 :mothers_name => panev,
                                 :street => "#{pteru} #{phsz}",
                                 :city   => phely,
                                 :zip_code => pirsz,
                                 :country => porsz,
                                 :information_source_id => @info.id
                               )
        end
        if kepve or kepvo
          role = role + " együttesen" if kepve
          role = role + " önállóan"   if kepvo
        end
        relation_type = role_to_relation_type role, pair_role, P2oRelationType, subrole
        rel = PersonToOrgRelation.find_by_person_id_and_organization_id_and_start_time_and_end_time_and_information_source_id_and_p2o_relation_type_id(
                                          person.id,    @org.id,            valtk,         valtv,       @info.id,                 relation_type.id )
        if !rel
          puts " >>>>>>>>>>>> creating new relation for:"
          puts PersonToOrgRelation.create!( :information_source => @info.id,
                                       :person_id => person.id,
                                       :organization_id => @org.id,
                                       :start_time => valtk,
                                       :end_time => valtv,
                                       :no_end_time => ( valtv.nil? ? true : false ),
                                       :p2o_relation_type_id  => relation_type.id,
                                       :role => ( tiszt.blank? ? nil : tiszt )
                                     )
        end
      elsif !is_person
        puts "  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> WIP - organization found: "
        puts adosz
        puts cgjsz
        puts org = Organization.find_by_tax_nr(adosz)
        puts org = Organization.find_by_trade_register_nr(cgjsz)
sleep 30000
      else
        # something went wrong
        puts "ERROR: : : : * * * * * * * * * * * * could not parse member"
        return false
      end
      @org.update_attribute :complexed_at, Time.now.to_date
    end

    def parse_simple a, *what
      puts hattol = to_date(a.search('mezo[@id="hattol"]').text.strip)
      puts hatig  = to_date(a.search('mezo[@id="hatig"]').text.strip)
      result = []
      what.each do |w|
        result << a.search("mezo[@id='#{w}']").text.strip
      end
      puts labj   = a.search("mezo[@id='labj']").text.strip
      puts valtk  = to_date(a.search('mezo[@id="valtk"]').text.strip)
      puts valtv  = to_date(a.search('mezo[@id="valtv"]').text.strip)
      puts bkelt  = to_date(a.search('mezo[@id="bkelt"]').text.strip)
      puts tkelt  = to_date(a.search('mezo[@id="tkelt"]').text.strip)
      if result.size == 1
        return result.first
      else
        return result
      end
    end

    n = 1
    dirname = 'db/complex/orgs/'
    Dir.foreach( dirname ) do |file|
      next if file == '.' or file == '..'
      n += 1; break if n > 2
      no_of_found = 0
      no_of_not_found = 0
      puts file
      puts file.inspect
      fc = file.length == 13 ? "0" + file : file # lemarad a 0 a file elejéről, amikor 0-val kezdődik a cégjegyzékszám
      cegjegyzekszam = fc.to_s[0..1] + '-' + fc.to_s[2..3] + '-' + fc.to_s[4..9]
      @new_org = false
      @org = Organization.find_or_create_by_trade_register_nr( cegjegyzekszam ) do |r| 
        r.name = cegjegyzekszam + rand(3000).to_s
        r.information_source_id = @info.id
        @new_org = true
      end

      f = File.open(dirname + file)
      doc = Nokogiri::XML(f, nil, 'ISO8859-2')

      puts "- - - - - - - - - - - "
      puts @org.inspect
      puts "- - - - - - - - - - - "
      puts doc.inspect
      puts "- - - - - - - - - - - "

      puts tax_nr = to_tax_nr( doc.search('//rovat[@id=0]/alrovat[@id=1]/mezo[@id="adosz"]').text.strip )
      puts cim = doc.search('//rovat[@id=0]/alrovat[@id=1]/mezo[@id="cim"]').text.strip
      puts irszam = cim[0..3]
      puts varos = cim.split(',').first[5..2000]
      puts utca =  cim.split(',').last.strip
      puts na =  doc.search('//rovat[@id=0]/alrovat[@id=1]/mezo[@id="nevalrovat"]').text.strip
      puts nev = doc.search("//rovat[@id=2]/alrovat[@id='#{na}']/mezo[@id='nev']").text.strip

      @org.street   = utca   if @new_org or @org.street.blank?
      @org.city     = varos  if @new_org or @org.city.blank?
      @org.zip_code = irszam if @new_org or @org.zip_code.blank?
      @org.save
      @org.name     = nev    if @new_org
      @org.save

      is_person = nil

      if @org.tax_nr == tax_nr
        puts ". . . . . . . . . . . . . . . . . . . . company found"
        # ------- tisztségviselők -------, cégjegyzsére jogosultak
        doc.search('//rovat[@id=13]/alrovat').each do |a|
          puts "- - - - - - cégjegyzésre jogosultak - - - - - -"
          parse_member a, "cégjegyzésre jogosult", "cégjegyzésre jogosult", "ugyanazon céget jegyzők"
        end
        doc.search('//rovat[@id=14]/alrovat').each do |a|
          puts "- - - - - - könyvvizsgálók - - - - - -"
          parse_member a, "könyvvizsgált cég", "könyvvizsgáló", "ugyanazon könyvvizsgáló"
        end
        doc.search('//rovat[@id=15]/alrovat').each do |a|
          puts "- - - - - - Felügyelő bizottsági tagok adatai - - - - - -"
          parse_member a, "Felügyelő Bizottsági tag", "Felügyelő Bizottság tagja", "ugynazon cégnél FB-tag"
        end
        doc.search('//rovat[@id=16]/alrovat').each do |a|
          puts "- - - - - - Jogelődök - - - - - -"
          parse_member a, "Jogelőd", "Jogutód"
        end
        doc.search('//rovat[@id=19]/alrovat').each do |a|
          puts "- - - - - - TB Szám - - - - - -"
          puts parse_simple a, 'tbsz'
        end
        doc.search('//rovat[@id=20]/alrovat').each do |a|
          puts "- - - - - - KSH Szám - - - - - -"
          puts parse_simple a, 'kshsz'
        end
        doc.search('//rovat[@id=16]/alrovat').each do |a|
          puts "- - - - - - Jogutód - - - - - -"
          jogutod = parse_simple a, 'jccjsz', 'atdat'
          puts jogutod_cegjegyzekszam = jogutod[0]
          puts jogutod_atalakulas     = to_date(jogutod[1])
        end
        doc.search('//rovat[@id=16]/alrovat').each do |a|
          puts "- - - - - - TB Szám - - - - - -"
          puts parse_simple a, 'tbsz'
        end
      else
        puts " ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !  company not found..."
      end

      f.close

    end
  end

end
