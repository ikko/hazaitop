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
      if kepve or kepvo
        role = role + " együttesen" if kepve
        role = role + " önállóan"   if kepvo
      end
      if is_person
        person = Person.find_by_name_and_mothers_name(pnev, panev)
        person = Person.find_by_name(pnev) unless person
        if person.nil?
          name = pnev.split(' ')
          last_name  = name[0]
          first_name = name[1..-1].join(' ') if name.length > 1
          puts person = Person.create!( :first_name => first_name,
                                 :last_name  => last_name,
                                 :mothers_name => panev,
                                 :street => "#{pteru} #{phsz}",
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
                                       :role => ( tiszt.blank? ? nil : tiszt )
                                     )
        end
      elsif !is_person
        puts "  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> WIP - organization found: "
        puts adosz
        puts cgjsz
        org = nil
        org = Organization.find_by_tax_nr(adosz) if !adosz.empty? 
        org = Organization.find_by_trade_register_nr( to_trade_register_nr(cgjsz) ) unless org
        org = Organization.find_by_trade_register_nr( to_trade_register_nr(cgjsz) ) unless org
        org = Organization.find_by_name( nev ) unless org
        org = Organization.create!( :name => nev,
                                    :trade_register_nr => cgjsz,
                                    :country           => orszag,
                                    :zip_code          => irsz,
                                    :city              => hely,
                                    :street            => "#{teru} #{hsz}",
                                    :information_source_id => @info.id
                                  ) unless org
        ap org
        puts relation_type = role_to_relation_type( role, pair_role, O2oRelationType )
        rel = InterorgRelation.find_by_organization_id_and_related_organization_id_and_start_time_and_end_time_and_information_source_id_and_o2o_relation_type_id(
                                       @org.id,             org.id,                    valtk,         valtv,       @info.id,                 relation_type.id )
        if !rel
          puts " >>>>>>>>>>>> creating new relation for:"
          rel InterorgRelation.create!( :information_source_id => @info.id,
                                       :related_organization_id => org.id,
                                       :organization_id => @org.id,
                                       :start_time => valtk,
                                       :end_time => valtv,
                                       :no_end_time => ( valtv.nil? ? true : false ),
                                       :o2o_relation_type_id  => relation_type.id,
                                       :role => ( tiszt.blank? ? nil : tiszt )
                                     )
        end
        ap rel
      else
        # something went wrong
        puts "ERROR: : : : * * * * * * * * * * * * could not parse member"
        return false
      end
      @org.update_attribute :complexed_at, Time.now.to_date
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

    no_of_found = 0
    no_of_not_found = 0
    n = 1
    dirname = 'db/complex/orgs/'
    Dir.foreach( dirname ) do |file|
      next if file == '.' or file == '..'
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
      @org.alternate_name  = nev   if @new_org

      is_person = nil

      if @org.tax_nr == tax_nr

        puts ". . . . . . . . . . . . . . . . . . . . company found"
        puts no_of_found += 1
        # ------- tisztségviselők -------, cégjegyzsére jogosultak
        doc.search('//rovat[@id=13]/alrovat').each do |a|
          puts "- - - - - - cégjegyzésre jogosultak - - - - - -"
          parse_member a, "cégjegyzésre jogosult", "cég jegyzésére jogosult", "ugyanazon céget jegyzők"
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
          Liquidation.create!( 
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
        doc.search('//rovat[@id=11]/alrovat').each do |a|
          puts "- - - - - - Vagyon - - - - - -"
          vagyon = parse_simple(a, 'szam')['szam'].to_i
          @org.stock = vagyon if stock > 0 and !@org.stock.blank?
        end
        @org.save
      else
        puts " ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !  company not found..."
        puts no_of_not_found += 1
      end

      f.close
      if @new_org  # azért mentjuk a végén a nevet, mert ha van már ilyen, akkor unique miatt nem fogja engedni
        @org.name     = nev    
        @org.save
      end
      puts "#{no_of_found} organizations found"
      puts "#{no_of_not_found} organizations not found"
      
    end
  end

end
