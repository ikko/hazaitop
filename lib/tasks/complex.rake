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

    def check_last_name last_name
      names = %w{Nagy Kovács Tóth Szabó Horváth Varga Kiss Molnár Németh Farkas Balogh Papp Takács Juhász Lakatos Mészáros Oláh Simon Rácz Fekete Szilágyi Török Fehér Gál Balázs Kis Szűcs Kocsis Pintér Fodor Orsós Szalai Magyar Takács}
      if names.include? last_name.capitalize
        return false
      else
        return true
      end
    end

    # initialize
    @info = InformationSource.find_or_create_by_name("Complex") do |r| 
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

    def to_trade_register_nr s
      return nil if s.blank?
      s = s.to_s
      s2 = s.length == 9 ? "0" + s : s # lemarad a 0 a file elejéről, amikor 0-val kezdődik a cégjegyzékszám
      cegjegyzekszam = s2[0..1] + '-' + s2[2..3] + '-' + s2[4..9]
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
          r.parsed = true
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
        return a if klass == P2oRelationType
        return b if klass == O2pRelationType  # ilyenkor fordítva lesz!! ésszel :)
      else
        relation_type = klass.find_or_create_by_name(role) do |r|
          r.name = role
          r.pair = klass.create!( :name => pair, :parsed => true )
          r.parsed = true
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
        return false if pnev.blank?  # van olyan, h csak egy id meg egy hatályosság van bnne, más nincs...
        pn = pnev.split(',')
        pnev = pn[0]
        tiszt2 = pn[1..-1].join(',') if pn.length > 1
        pn = pnev.split('(')
        pnev = pn[0]
        tiszt2 = pn[1..-1].join('(') if pn.length > 1
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
      puts tagsk    = to_date(a.search('mezo[@id="tagsk"]'  ).text.strip) # tagságnál ha van date, ecceruen felülcsapjuk a váoltozást azzal
      valtk = tagsk unless valtk
      valtk = jogvk unless valtk
      puts ':: valtv:'
      puts valtv    = to_date(a.search('mezo[@id="valtv"]'  ).text.strip)
      puts tagsv    = to_date(a.search('mezo[@id="tagsv"]'  ).text.strip) # tagságnál ha van date, ecceruen felülcsapjuk a váoltozást azzal
      valtv = tagsv unless valtv
      valtv = jogvv unless valtv
      puts tnytsz   = a.search('mezo[@id="knytsz"]' ).text.strip
      puts knytsz   = a.search('mezo[@id="tnytsz"]' ).text.strip
      puts knyh     = a.search('mezo[@id="knyh"]'   ).text.strip
      puts ':: bkelt:'
      puts bkelt    = to_date(a.search('mezo[@id="bkelt"]'  ).text.strip)
      puts ':: tkelt:'
      puts tkelt    = to_date(a.search('mezo[@id="tkelt"]'  ).text.strip)
      puts jelentos  = a.search('mezo[@id="j"]'  ).text.strip
      puts tobbsegi  = a.search('mezo[@id="t"]'  ).text.strip
      puts kozvetlen = a.search('mezo[@id="k"]'  ).text.strip
      %w{I Y T X 1}.include?(jelentos.upcase)  ? jelentos = true  : jelentos = false
      %w{I Y T X 1}.include?(tobbsegi.upcase)  ? tobbsegi = true  : tobbsegi = false
      %w{I Y T X 1}.include?(kozvetlen.upcase) ? kozvetlen = true : kozvetlen = false
      szav = a.search('mezo[@id="sz1"]'  ).text.strip
      szavazat_50_szazalek_felett  = ( a.search('mezo[@id="sz1"]'  ).text.strip.upcase == 'X' ? true : false )
      szavazat_tobbsegi_befolyas   = ( a.search('mezo[@id="sz2"]'  ).text.strip.upcase == 'X' ? true : false )
      szavazat_egyeduli_reszvenyes = ( a.search('mezo[@id="sz3"]'  ).text.strip.upcase == 'X' ? true : false )
      if kepve or kepvo
        role = role + " együttesen" if kepve
        role = role + " önállóan"   if kepvo
        pair_role = pair_role + " együttesen" if kepve
        pair_role = pair_role + " önállóan"   if kepvo
      end
      if is_person
        person = Person.find_by_name_and_mothers_name(pnev, panev)
        person = Person.find_by_name_and_city_and_street(pnev, phely, "#{pteru} #{phsz}".strip) unless person
        name = pnev.split(' ')
        last_name  = name[0]
        first_name = name[1..-1].join(' ') if name.length > 1
        if !person and check_last_name( last_name ) 
          person = Person.find_by_name(pnev)
        end
        if person.nil?
          puts person = Person.create!( :first_name => first_name,
                                 :last_name  => last_name,
                                 :mothers_name => panev,
                                 :street => "#{pteru} #{phsz}".strip,
                                 :city   => phely,
                                 :zip_code => pirsz,
                                 :country => porsz,
                                 :information_source_id => @info.id
                               )
        end
        puts relation_type = role_to_relation_type( role, pair_role, P2oRelationType, subrole )
        rel = PersonToOrgRelation.find_by_person_id_and_organization_id_and_start_time_and_end_time_and_information_source_id_and_p2o_relation_type_id(
                                          person.id,    @org.id,            valtk,         valtv,       @info.id,                 relation_type.id )
        if !rel
          puts " >>>>>>>>>>>> creating new relation for:"
          puts PersonToOrgRelation.create!( :information_source_id => @info.id,
                                       :person_id => person.id,
                                       :organization_id => @org.id,
                                       :start_time => valtk,
                                       :end_time => valtv,
                                       :no_end_time => ( valtv.nil? ? true : false ),
                                       :p2o_relation_type_id  => relation_type.id,
                                       :erased_at => tkelt,
                                       :role => ( tiszt.blank? ? nil : tiszt ),
                                       :role2 => ( tiszt2.blank? ? nil : tiszt2 ),
                                       :note => labjegyzet,
                                       :jelentos => jelentos,
                                       :tobbsegi => tobbsegi,
                                       :kozvetlen => kozvetlen, 
                                       :szavazat_50_szazalek_felett =>  szavazat_50_szazalek_felett,
                                       :szavazat_tobbsegi_befolyas  =>  szavazat_tobbsegi_befolyas,
                                       :szavazat_egyeduli_reszvenyes => szavazat_egyeduli_reszvenyes,
                                       :parsed => true
                                     )
        end
      elsif !is_person
        puts "  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> WIP - organization found: "
        puts adosz
        puts cgjsz
        org = nil
        org = Organization.find_by_tax_nr(adosz) if !adosz.empty? and !adosz.blank?
        org = Organization.find_by_trade_register_nr( to_trade_register_nr(cgjsz) ) if !org and !cgjsz.empty? and !cgjsz.blank?
        org = Organization.find_by_name( nev ) if !org and !nev.blank? and !nev.empty?
        org = Organization.create!( :name => nev,
                                    :trade_register_nr => to_trade_register_nr(cgjsz),
                                    :country           => orszag,
                                    :zip_code          => irsz,
                                    :city              => hely,
                                    :street            => "#{teru} #{hsz}".strip,
                                    :information_source_id => @info.id
                                  ) unless org
        ap org
        puts relation_type = role_to_relation_type( role, pair_role, O2oRelationType )
        rel = InterorgRelation.find_by_organization_id_and_related_organization_id_and_start_time_and_end_time_and_information_source_id_and_o2o_relation_type_id(
                                       @org.id,             org.id,                    valtk,         valtv,       @info.id,                 relation_type.id )
        if !rel
          puts " >>>>>>>>>>>> creating new relation for:"
          rel = InterorgRelation.create!( :information_source_id => @info.id,
                                       :related_organization_id => org.id,
                                       :organization_id => @org.id,
                                       :start_time => valtk,
                                       :end_time => valtv,
                                       :no_end_time => ( valtv.nil? ? true : false ),
                                       :o2o_relation_type_id  => relation_type.id,
                                       :erased_at => tkelt,
                                       :role => ( tiszt.blank? ? nil : tiszt ),
                                       :role2 => ( tiszt2.blank? ? nil : tiszt2 ),
                                       :note => labjegyzet,
                                       :jelentos => jelentos,
                                       :tobbsegi => tobbsegi,
                                       :kozvetlen => kozvetlen,
                                       :szavazat_50_szazalek_felett =>  szavazat_50_szazalek_felett,
                                       :szavazat_tobbsegi_befolyas  =>  szavazat_tobbsegi_befolyas,
                                       :szavazat_egyeduli_reszvenyes => szavazat_egyeduli_reszvenyes,
                                       :parsed => true
                                     )
        end
        ap rel
      else
        # something went wrong
        puts "ERROR: : : : * * * * * * * * * * * * could not parse member"
        return false
      end
      
      @org.update_attributes :complexed_at => Time.now.to_date
    end

    def parse_simple a, *what
      result = {}
      puts result['hattol'] = to_date(a.search('mezo[@id="hattol"]').text.strip)
      puts result['hatig']  = to_date(a.search('mezo[@id="hatig"]').text.strip)
      puts result['labj']   = a.search("mezo[@id='labj']").text.strip.gsub('<ujsor/>',"\n")
      puts result['valtk']  = to_date(a.search('mezo[@id="valtk"]').text.strip)
      puts result['valtv']  = to_date(a.search('mezo[@id="valtv"]').text.strip)
      puts result['bkelt']  = to_date(a.search('mezo[@id="bkelt"]').text.strip)
      puts result['tkelt']  = to_date(a.search('mezo[@id="tkelt"]').text.strip)
      result['from'] = result['valtk'] if result['valtk']
      result['from'] = result['hattol'] if result['hattol']
      result['to'] = result['valtv'] if result['valtv']
      result['to'] = result['hatig'] if result['hatig']
      what.each do |w|
        result[w] = a.search("mezo[@id='#{w}']").text.strip.gsub('<ujsor/>',"\n")
      end
      return result
    end

    def downcase_hu x
      x.downcase.gsub('É','é').gsub('Á','á').gsub('Ő','ő').gsub('Ú','ú').gsub('Ű','ű').gsub('Ó','ó').gsub('Ü','ü').gsub('Ö','ö').gsub('Í','í')
    end

    no_of_found = 0
    no_of_not_found = 0
    n = 1
    xa = 0; xb = 0; xc = 0;
    dirname = 'db/complex/orgs/'
    logname = "db/complex/import-#{Time.now.to_s(:db).gsub(' ','-').gsub(':','-').gsub('/','-')}.log"
    logfile = File.open(logname, 'w' )
    forwarding = true
    puts "counting..."
    Dir.foreach( dirname ) do |file|
      next if file == '.' or file == '..'
=begin      
      if forwarding and file == '509010664.xml'
        forwarding = false     
        xc = xa;
      end
      xa = xa + 1;
      next if forwarding
      xb = xb + 1;
      next
=end
      n += 1; break if n > 20
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
      f.close


      f = File.open(dirname + file)
      sf = ""
      f.each do |l|
        l = '  ' + l if l[0..3] == '<rov' or l[0..3] == '</ro'
        l = '    ' + l if l[0..3] == '<alr' or l[0..3] == '</al'
        l = '      ' + l if l[0..3] == '<mez' or l[0..3] == '</me'
        sf << l
      end
      @org.complex_xml = sf


      puts "- - - - - - - - - - - "
      puts @org.inspect
      puts "- - - - - - - - - - - "




      puts tax_nr = to_tax_nr( doc.search('//rovat[@id=0]/alrovat/mezo[@id="adosz"]').text.strip )
      puts cim = doc.search('//rovat[@id=0]/alrovat[@id=1]/mezo[@id="cim"]').text.strip
      if cim and !cim.empty?
        puts irszam = cim[0..3] 
        puts varos = cim.split(',').first[5..2000]
        puts utca =  cim.split(',').last.strip
      end
      puts na =  doc.search('//rovat[@id=0]/alrovat[@id=1]/mezo[@id="nevalrovat"]').text.strip
      puts nev = doc.search("//rovat[@id=2]/alrovat[@id='#{na}']/mezo[@id='nev']").text.strip

      @org.street   = utca   if @new_org or @org.street.blank?
      @org.city     = varos  if @new_org or @org.city.blank?
      @org.zip_code = irszam if @new_org or @org.zip_code.blank?
      @org.alternate_name  = nev   if @new_org

      if nev and (@new_org or 
                  downcase_hu(@org.name).match( downcase_hu(nev.split(' ')[0]).scan(/[a-zéáíőúöüóű]/).join ) or
                  @org.name[0..15].scan(/[0-9]/).size > 8
                 )
        logfile.puts "matched: #{file} -::-  #{@org.id} -::- #{@org.name} -::- #{nev} -::- #{Time.now}"
      else
        logfile.puts "NOT matched: #{file} -::-  #{@org.id} -::- #{@org.name} -::- #{nev} -::- #{Time.now}"
        next
      end

      is_person = nil

      @org.tax_nr = tax_nr if !tax_nr.empty?

      puts ". . . . . . . . . . . . . . . . . . . . company found"
      doc.search('//rovat[@id=11]/alrovat').each do |a|
        puts "- - - - - - Vagyon - - - - - -"
        vagyon = parse_simple(a, 'szam')['szam'].to_i
        @org.stock = vagyon if vagyon > 0 and !@org.stock.blank?
      end
      doc.search('//rovat[@id=13]/alrovat').each do |a|
        puts "- - - - - - cégjegyzésre jogosultak - - - - - -"
        parse_member a, "Cég jegyzésére jogosult", "Cégjegyzésre jogosult", "ugyanazon céget jegyzi"
      end
      doc.search('//rovat[@id=14]/alrovat').each do |a|
        puts "- - - - - - könyvvizsgálók - - - - - -"
        parse_member a, "Könyvvizsgáló", "Könyvvizsgált cég", "ugyanazon könyvvizsgáló"
      end
      doc.search('//rovat[@id=15]/alrovat').each do |a|
        puts "- - - - - - Felügyelő bizottsági tagok adatai - - - - - -"
        parse_member a, "Felügyelő Bizottsági tag", "Felügyelő Bizottság tagja", "ugynazon társaságnál FB-tag"
      end
      doc.search('//rovat[@id=16]/alrovat').each do |a|
        puts "- - - - - - Jogelődök - - - - - -"
        parse_member a, "Jogelőd", "Jogutód", "közös jogelőd vagy jogutód"
      end
      doc.search('//rovat[@id=19]/alrovat').each do |a|
        puts "- - - - - - TB Szám - - - - - -"
        h = parse_simple(a, 'tbsz')
        if !h['tbsz'].blank? 
          if @org.social_security_number.blank? or ( h['from'] and @org.social_security_number_from and @org.social_security_number_from < h['from'] )
            @org.social_security_number      = h['tbsz']
            @org.social_security_number_from = h['from']
          end
        end
      end
      doc.search('//rovat[@id=20]/alrovat').each do |a|
        puts "- - - - - - KSH Szám - - - - - -"
        h = parse_simple(a, 'kshsz')
        if !h['kshsz'].blank? 
          if @org.ksh_number.blank? or ( h['from'] and @org.ksh_number_from and @org.ksh_number_from < h['from'] )
            @org.ksh_number      = h['kshsz']
            @org.ksh_number_from = h['from']
          end
        end
      end
      doc.search('//rovat[@id=24]/alrovat').each do |a|
        puts "- - - - - - Megszuntek nyilvánítás - - - - - -"  # ez ugye amugy esgyser lehetne csak elvileg... bár ki tudja mit csinálnak a bíroságok....
        h = parse_simple(a, 'mnydat')
        if !to_date(h['mnydat']).blank? 
          if @org.ceased_at.blank? or ( h['from'] and @org.ceased_from and @org.ceased_from < h['from'] )
            @org.ceased_at   = to_date( h['mnydat'] )
            @org.ceased_from = h['from']
          end
        end 
      end
      doc.search('//rovat[@id=26]/alrovat').each do |a|
        puts "- - - - - - Végelszámolás - - - - - -"  
        type = 'vegelszamolas'
        h = parse_simple(a, 'vegk', 'vegv', 'kod', 'ne', 'hird')
        kezdete = to_date(h['vegk'])
        vege    = to_date(h['vegv'])
        if kezdete 
          liq = Liquidation.find_by_organization_id_and_type_and_process_start( @org.id, type, kezdete )
          if !liq
            Liquidation.create!( :process_start => kezdete, 
                                 :process_end   => vege, 
                                 :start_time    => h['from'], 
                                 :end_time => h['to'], 
                                 :organization_id => @org.id,
                                 :type => type,
                                 :simple => ( h['ne'] == 'x' ? true : false ),
                                 :stays  => ( h['kod'] == 'x' ? true : false ),
                                 :note   => h['hird']
                               )
          end
        end 
      end
      doc.search('//rovat[@id=27]/alrovat').each do |a|
        puts "- - - - - - Csődeljárás - - - - - -"  
        type = 'csodeljaras'
        h = parse_simple(a, 'szank', 'szanv', 'labj')
        kezdete = to_date(h['szank'])
        vege    = to_date(h['szanv'])
        if kezdete 
          liq = Liquidation.find_by_organization_id_and_type_and_process_start( @org.id, type, kezdete )
          if !liq
            Liquidation.create!( :process_start => kezdete, 
                                 :process_end   => vege, 
                                 :start_time    => h['from'], 
                                 :end_time => h['to'], 
                                 :organization_id => @org.id,
                                 :type => type,
                                 :note   => h['labj']
                               )
          end
        end 
      end
      doc.search('//rovat[@id=28]/alrovat').each do |a|
        puts "- - - - - - Felszámolás - - - - - -"  
        type = 'felszamolas'
        h = parse_simple(a, 'felszk', 'felszv', 'labj', 'kod')
        kezdete = to_date(h['felszk'])
        vege    = to_date(h['felszv'])
        if kezdete 
          liq = Liquidation.find_by_organization_id_and_type_and_process_start( @org.id, type, kezdete )
          if !liq
            Liquidation.create!( :process_start => kezdete, 
                                 :process_end   => vege, 
                                 :start_time    => h['from'], 
                                 :end_time => h['to'], 
                                 :organization_id => @org.id,
                                 :type => type,
                                 :stays  => ( h['kod'] == 'x' ? true : false ),
                                 :note   => h['labj']
                               )
          end
        end 
      end

      doc.search('//rovat[@id=48]/alrovat').each do |a|
        puts "- - - - - - Kozhasznusagi fokozat - - - - - -"
        h = parse_simple(a, 'kozh', 'kkozh')
        if h['kozh'] == 'x'  
          if @org.kozhasznu.blank? or ( h['from'] and @org.kozhasznu_from and @org.kozhasznu_from < h['from'] )
            @org.kozhasznu = true
            @org.kozhasznu_from = h['from']
          end
        end
        if h['kkozh'] == 'x'  
          if @org.kiemelten_kozhasznu.blank? or ( h['from'] and @org.kiemelten_kozhasznu_from and @org.kiemelten_kozhasznu_from < h['from'] )
            @org.kiemelten_kozhasznu = true
            @org.kiemelten_kozhasznu_from = h['from']
          end
        end
      end

      doc.search('//rovat[@id=49]/alrovat').each do |a|
        puts "- - - - - - Előző cégjegyzékszámok - - - - - -"  
        h = parse_simple(a, 'cgjsz', 'labj')
        cegjegyzekszam = to_trade_register_nr( h['cgjsz'] )
        c = TradeRegisterNumber.find_by_organization_id_and_nr( @org.id, cegjegyzekszam )
        if !c
        TradeRegisterNumber.create!( 
                             :start_time    => h['from'], 
                             :end_time => h['to'], 
                             :organization_id => @org.id,
                             :nr => cegjegyzekszam,
                             :note   => h['labj']
                           )
        end 
      end

      doc.search('//rovat[@id=54]/alrovat').each do |a|
        puts "- - - - - - állami tulajdonosi joggyakorló - - - - - -"
        parse_member a, "állami tulajdonosi joggyakorló", "állami tulajdonosi joggyakorló"
      end

      doc.search('//rovat[@id=57]/alrovat').each do |a|
        puts "- - - - - - Eltiltás alatt lévő tisztségviselők és cégvezetők - - - - - -"  
        h = parse_simple(a, 'nev', 'anev', 'akezd', 'aveg', 'tkelt')
        kezdete = to_date(h['akezd'])
        vege    = to_date(h['aveg'])
        person = Person.find_by_name_and_mothers_name( h['nev'], h['anev'] )
        name = h['nev'].split(' ')
        last_name  = name[0]
        first_name = name[1..-1].join(' ') if name.length > 1
        if !person and check_last_name( last_name ) 
          person = Person.find_by_name( h['nev'] )
        end
        unless person
          person = Person.create!( :first_name => first_name, :last_name => last_name, :mothers_name => h['anev'], :information_source_id => @info.id )
        end
        relation_type = role_to_relation_type( "Eltiltás alatt", "Eltiltás alatt", P2oRelationType, "Ugyanazon cégnél eltiltottak" )
        rel = PersonToOrgRelation.find_by_person_id_and_organization_id_and_start_time_and_end_time_and_information_source_id_and_p2o_relation_type_id(
                                          person.id,    @org.id,            kezdete,       vege,        @info.id,                 relation_type.id )
        if !rel
          puts " >>>>>>>>>>>> creating new relation for:"
          rel = PersonToOrgRelation.create!( :information_source_id => @info.id,
                                     :person_id => person.id,
                                     :organization_id => @org.id,
                                     :start_time => kezdete,
                                     :end_time => vege,
                                     :no_end_time => ( vege.nil? ? true : false ),
                                     :p2o_relation_type_id  => relation_type.id,
                                     :note => ( h['labj'].blank? ? nil : h['labj'] ),
                                     :erased_at => h['tkelt'],
                                     :parsed => true
                                   )
        end
        ap rel
      end

=begin
      doc.search('//rovat[@id=99]/alrovat').each do |a|
        puts "- - - - - - Hirdetmények- - - -"
        hird = parse_simple(a, 'szoveg', 'labj' 'tipus', 'tipusnev', 'kozdatum', 'ugyszam', 'eugyszam', 'birosag', 'felsz', 'felsz_cim', 'felsz_cjsz',
                            'felszbizt1_nev', 'felszbizt1_cim', 'felszbizt1_irsz', 'felszbizt2_nev', 'felszbizt2_cim', 'felszbizt2_irsz', 'benyujtdatum', 'fkozdatum', 'jogerodatum')
        if !hird['szoveg'].blank?
          anno = Announcement.find_by_organization_id_and_content( @org.id, hird['szoveg'] )
          if !anno
            Announcement.create!( :content => hird['szoveg'],
                                  :organization_id => @org.id,
                                  :start_time        => to_date(hird['hattol']), 
                                  :end_time          => to_date(hird['hatig']),
                                  :labjegyezet       => hird['labj'],
                                  :tipus             => hird['tipus'],
                                  :tipusnev          => hird['tipusnev'],
                                  :issued_at         => to_date(hird['kozdatum']),
                                  :ugyszam           => hird['ugyszam'],
                                  :eugyszam          => hird['eugyszam'],
                                  :birosag           => hird['birosag'],
                                  :felszamolo_neve   => hird['felsz'],
                                  :felszamolo_cime   => hird['felsz_cim'],
                                  :felszamolo_cgjsz  => hird['felsz_cjsz'],
                                  :felszbizt1_nev    => hird['felszbizt1_nev'],
                                  :felszbizt1_cim    => hird['felszbizt1_cim'],
                                  :felszbizt1_irsz   => hird['felszbizt1_irsz'],
                                  :felszbizt2_nev    => hird['felszbizt2_nev'],
                                  :felszbizt2_cim    => hird['felszbizt2_cim'],
                                  :felszbizt2_irsz   => hird['felszbizt2_irsz'],
                                  :legal_at          => to_date(hird['jogerodatum']),
                                  :submitted_at      => to_date(hird['fkozdatum'])
                                )
          end
        end
      end
=end      
      doc.search('//rovat[@id=103]/alrovat').each do |a|
        puts "- - - - - - közkereseti társaság tagjai - - - - - -"
        parse_member a, "Kkt. tag", "Kkt. tag", "kkt. tag ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=106]/alrovat').each do |a|
        puts "- - - - - - beltagok tagjai - - - - - -"
        parse_member a, "Bt. beltag", "Bt. beltag", "Bt. beltag ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=107]/alrovat').each do |a|
        puts "- - - - - - egyesülés tagjai - - - - - -"
        parse_member a, "Egyesülés tagja", "Egyesülés tagja", "Egyesülés tagja ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=108]/alrovat').each do |a|
        puts "- - - - - - közös vállalat tagjai - - - - - -"
        parse_member a, "Közös vállalat tagja", "Közös vállalat tagja", "Közös válallat tagja ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=109]/alrovat').each do |a|
        puts "- - - - - - kft tagjai - - - - - -"
        parse_member a, "Kft. tag", "Kft. tag", "Kft. tagja ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=110]/alrovat').each do |a|
        puts "- - - - - - egyszeméyles rt. alapító - - - - - -"
        parse_member a, "Egyszeméyles rt. alapító / részvényes", "Egyszeméyles rt. alapító / részvényes", "rt. alapító / részvényes ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=111]/alrovat').each do |a|
        puts "- - - - - - egyéni cég tulajdonosa - - - - - -"
        parse_member a, "Egyéni cég tulajdonosa", "Egyéni cég tulajdonosa", "egyéni cég tulajdonosa ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=120]/alrovat').each do |a|
        puts "- - - - - - részvényesek - - - - - -"
        parse_member a, "Részvényes", "Részvényes", "részvényes ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=206]/alrovat').each do |a|  
        puts "- - - - - - kultagok tagjai - - - - - -"
        parse_member a, "Bt. kültag", "Bt. kültag", "bt. kültag ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=213]/alrovat').each do |a|  
        puts "- - - - - - cégtagok tagjai - - - - - -"
        parse_member a, "Cégtag", "Cégtag", "cégtag ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=214]/alrovat').each do |a|  
        puts "- - - - - - kht tagok tagjai - - - - - -"
        parse_member a, "Kht. tag", "Kht. tag", "kht. tag ugyanazon társaságnál"
      end
      doc.search('//rovat[@id=99017]/alrovat').each do |a|  
        puts "- - - - - - Mérlegadatok (11 soros) - - - -"
        h = parse_simple(a, 'kezd', 'veg' 'szorzo', 'penz', 'a_eredm', 'aktiv_el', 'eszk', 'celtart', 'netto', 'forgo', 'kotelez', 'm_eredm', 'passziv_el', 'toke', 'u_eredm', 'labj')
        if !h['a_eredm'].blank?
          fina = Financial.find_by_start_time_and_end_time_and_a_eredm_and_organization_id( to_date(h['kezd']), to_date(h['veg']), h['a_eredm'].to_i, @org.id )
          if !fina
            fine = Financial.create!(    :organization_id   => @org.id,
                                  :start_time        => to_date(h['kezd']), 
                                  :end_time          => to_date(h['veg']),
                                  :penznem           => h['penz'],
                                  :a_eredm           => h['a_eredm'].to_i * h['szorzo'].to_i,
                                  :aktiv_el          => h['aktiv_el'].to_i * h['szorzo'].to_i,
                                  :eszk              => h['eszk'].to_i * h['szorzo'].to_i,
                                  :celtart           => h['celtart'].to_i * h['szorzo'].to_i,
                                  :netto             => h['netto'].to_i * h['szorzo'].to_i,
                                  :forgo             => h['forgo'].to_i * h['szorzo'].to_i,
                                  :kotelez           => h['kotelez'].to_i * h['szorzo'].to_i,
                                  :m_eredm           => h['m_eredm'].to_i * h['szorzo'].to_i,
                                  :passziv_el        => h['passziv_el'].to_i * h['szorzo'].to_i,
                                  :toke              => h['toke'].to_i * h['szorzo'].to_i,
                                  :u_eredm           => h['u_eredm'].to_i * h['szorzo'].to_i,
                                  :year              => to_date(h['kezd']).try.year
                                )
          end
          ap fina
        end
      end
      @org.save

      f.close
      if @new_org  # azért mentjuk a végén a nevet, mert ha van már ilyen, akkor unique miatt nem fogja engedni
        @org.name     = nev    
        @org.save
        no_of_not_found += 1
      else
        no_of_found += 1
      end
      puts "#{no_of_found} organizations found"
      puts "#{no_of_not_found} organizations are new"
      
    end

    puts "counted: #{xa}, #{xb}, #{xc}"

    logfile.close

  end

end
