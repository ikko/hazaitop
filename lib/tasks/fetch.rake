# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'open-uri'

namespace :fetch do
  desc 'fetch ertesito'
  task :ertesito => :environment do

    require 'pdftohtmlr'
    include PDFToHTMLR

    LMAX = 4000

    @log = File.open('db/notification_summary.txt', 'a')

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

    @log.puts "////////////////////////////////////////////////////////////////////////"
    @log.puts "starting to process at #{Time.now} in #{Rails.root}"
    @log.puts "------------------------------------------------------------------------"

#    for lapid in 319220..319999 do 
    for lapid in 319422..328837 do 
      # 282615 a vége
      puts lapid
      @lines = []
      # ha még nincs meg ez az értesítő
      note = Notification.find_by_number(lapid.to_s) 
      if !note
        # ha van tempfile, használjuk azt
        if false # TODO File.exist?("db/kbe/#{lapid}.txt")
          puts "reading txt tempfile..."
          tempfile = File.open("db/kbe/#{lapid}.txt", 'r')
          begin
            line = tempfile.gets
            if !line.nil?
              @lines << line.chop
            end
          end until line.nil?
          tempfile.close
          puts "there are #{@lines.size} lines in the tempfile..."
        else 
          # puts "FORWARDING..." ; next # TODO
          # ha nincs pdf file se, akkor próbáljuk meg letölteni
          puts "no tempfile found at db/kbe/#{lapid}.txt or tempfile is corrupted... TODO" # TODO
          if !File.exist?(Rails.root + "db/kbe/#{lapid}.pdf")
            puts "downloading... to db/kbe/#{lapid}.pdf from"
            puts "http://www.kozbeszerzes.hu/lid/ertesito/pid/0/ertesitoProperties?objectID=Lapszam.portal_#{ lapid }"
            ertesito = Nokogiri::HTML(open("http://www.kozbeszerzes.hu/lid/ertesito/pid/0/ertesitoProperties?objectID=Lapszam.portal_#{ lapid }"))
            if ertesito.css('a.attach').blank?
              puts "skipping #{lapid}, download failed... no attach class found in html, no pdf to download?"
              next
            end
            dl =  Nokogiri::HTML(open('http://www.kozbeszerzes.hu/' + ertesito.css('a.attach').last['href']))
            a = dl.css('a').last['href'].split('/').last.match(/\d+/).to_s
            filepath = dl.css('a').last['href'].split('/')[0..-2].join('/') + "/KÉ%20#{a}%20teljes_alairt.pdf.pdf"
            system "cd #{Rails.root + 'db/kbe'} && wget -O #{lapid}.pdf #{filepath}"
            if File.stat(Rails.root + "db/kbe/#{lapid}.pdf").size == 0
              filepath = dl.css('a').last['href']
              system "cd #{Rails.root + 'db/kbe'} && wget -O #{lapid}.pdf #{filepath}"
              puts "régi pdf elnevezés..."
            end
          else # ha van pdf, akkor használjuk azt
            puts "pdf file already downloaded, using that..."
          end
          if !File.exist?(Rails.root + "db/kbe/#{lapid}.pdf") or File.stat(Rails.root + "db/kbe/#{lapid}.pdf").size == 0
            puts "skipping #{Rails.root.to_s}/db/kbe/#{ lapid }.pdf, no file found or file is empty: probably 404..."
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
        end
      else
        puts "Skipping: notification already in database..."
        puts note.inspect
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

      @log.puts(name)

      #     if !Notification.find_by_name(name)
      if ertesito and ertesito.css(".ertesitoLapszamInfoful span").last
        date = ertesito.css(".ertesitoLapszamInfoful span").last.text.to_date
      else
        date = name[-11..-1].to_date
      end
      note = Notification.create!( :name => name, :issued_at => date,  :number => lapid )

      @sum = 0
      @sums = []
      @ertekek = []
      @lines.each_with_index do |v, i|
        if v == "tájékoztató"
          if @lines[i + 1] == "az eljárás eredményéről"
            puts '======================================='
            puts case_number = @lines[i - 6].split(" ").last.try[1..-2]
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
                                                           "Az ajánlatkérő más ajánlatkérők nevében folytatja-e le a közbeszerzési eljárást?", i)

            puts ":: ELNEVEZÉS"
            puts c_elnevezes = look_between("II.1.1) Az ajánlatkérő által a szerződéshez rendelt elnevezés",
                                            "II.1.2) A szerződés típusa, valamint a teljesítés helye ( Csak azt a kategóriát válassza – építési beruházás,", i)
            puts ":: TÁRGY, MENNYISÉG"
            targy1 = look_between("II.1.4) A szerződés vagy a közbeszerzés(ek) tárgya, mennyisége",
                                  "II.1.5) Közös Közbeszerzési Szójegyzék (CPV)", i)
            targy2 = look_between("II.1.5) A szerződés vagy a közbeszerzés(ek) tárgya, mennyisége",
                                  "II.1.6) Közös Közbeszerzési Szójegyzék (CPV)", i)
            puts c_targy = targy1.class == Range ? targy2 : targy1

            puts ":: teljesítés helye"
            puts c_telj_helye = look("A teljesítés helye", i)

            puts ":: szerődés tipusa"
            puts c_tipus = look_x_before_between("II.1.2) A szerződés típusa, valamint a teljesítés helye", "II.1.3)", i)

            puts ":: keretszerződés v dbr?"
            # keretszerzodés?
            keret1 = look_x_after_between("II.1.2) A hirdetmény a következők valamelyikével kapcsolatos",
                                          "II.1.4)", i)
            keret2 = look_x_after_between("II.1.3) A hirdetmény a következők valamelyikével kapcsolatos",
                                          "II.1.5)", i)

            puts c_keret = keret1.class == Range ? keret2 : keret1



            puts ":: milyen a keretmegállapodás"
            puts look_x_after_between("III.1.3) A keretmegállapodás megkötésére milyen eljárás alkalmazásával került sor?",
                                      "III.2)", i)


            puts ":: CPV"
            # kétféle is lehet:
            cpv1 = look_cpv_between("II.1.5) Közös Közbeszerzési Szójegyzék (CPV)", "II.2) A szerződés(ek) értéke", i)
            cpv2 = look_cpv_between("II.1.6) Közös Közbeszerzési Szójegyzék (CPV)", "II.2) A szerződés(ek) értéke", i)
            puts c_cpv = cpv1.class == Range ? cpv2 : cpv1


            puts ":: ÉRTÉK"
            # érták
            h = look_price_between("II.2) A szerződés(ek) értéke", 
                                   "III.1.1)", i)


            puts ":: ÁFA"
            # áfa info:

            puts c_sum_value_afa = look_x_after_between("II.2) A szerződés(ek) értéke", "III.1.1)", i)

            c_currency = h[:currency]
            c_sum_value = h[:value]
            c_original_sum_value = h[:original]
            puts h.inspect
            puts commify( h[:value] )

            # az aktuális hirdetmény vége
            puts v = get_pos("E hirdetmény feladásának dátuma", i)

            # nézzük, kikkel szerződtek

            j = get_pos("IV. szakasz", i)

            while j and j < v do

              puts c_number = look("A Szerzõdés száma", j) 
              puts c_name = look_between("Megnevezése", "IV.1)", j)
              puts c_no_of_proposals = look("A benyújtott ajánlatok száma", j).to_i
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
              puts commify( h[:value] )
              puts c_becsult = h[:value]


              puts ":: Az ellenszolgáltatás szerződésbeli összege"

              # szerződéses összeg 
              h = look_price_between( "Az ellenszolgáltatás szerződésbeli összege", 
                                     "a legalacsonyabb ellenszolgáltatást tartalmazó ajánlat", j)

              puts ":: ÁFA"
              # áfa info:
              puts c_ertek_afa = look_x_after_between( "Az ellenszolgáltatás szerződésbeli összege",
                                                      "a legalacsonyabb ellenszolgáltatást tartalmazó ajánlat", j)
              puts h.inspect
              puts commify( h[:value] )
              puts c_ertek = h[:value]
              puts c_eredeti_ertek = h[:original]

              @sum = @sum + h[:value]
              @sums << commify( h[:value] )

              e = look("V.2.2) Ha az eljárás eredménytelen, illetve szerződéskötésre nem kerül sor, ennek indoka", j)

              if e != "V.2.3) A nyertes ajánlattevőnek a közbeszerzési törvény 70. §-ának (2) bekezdése szerinti minősítése"
                eredmenytelen = true
              else
                eredmenytelen = false
              end

              break if c_ertek == 0 and eredmenytelen

              @ertekek << [ h[:value], commify( h[:value] ), megrendelo, vallalkozo, c_ertek_afa,  case_number ]

              if vallalkozo[-4..-1] == ' Kft' or
                vallalkozo[-3..-1] == ' Rt' or
                vallalkozo[-3..-1] == ' Bt' or
                vallalkozo[-4..-1] == ' Zrt' or
                vallalkozo[-5..-1] == ' Nyrt'

                vallalkozo = vallalkozo + '.'
              end

              vall = Organization.find_by_name(vallalkozo)
              if !vall
                vall = Organization.create( :name => vallalkozo,
                                           :street => c_cim,
                                           :city => c_varos,
                                           :zip_code => c_irszam,
                                           :phone => c_telefon,
                                           :fax => c_fax,
                                           :email_address => c_email,
                                           :internet_address => c_url,
                                           :information_source_id => info.id,
                                           :user_id => user.id
                                          )
              end
              if !vall # hack, hogy nil id-val teegye be, mert valami nem okés a parsolt adattal
                vall = Struct.new(:id).new
              end
              megr = Organization.find_by_name(megrendelo)
              if !megr
                megr = Organization.create( :name => megrendelo,
                                           :street => m_cim,
                                           :city => m_varos,
                                           :zip_code => m_irszam,
                                           :phone => m_telefon,
                                           :fax => m_fax,
                                           :email_address => m_email,
                                           :internet_address => m_url,
                                           :information_source_id => info.id,
                                           :user_id => user.id
                                          ) 
              end
              puts m_tevekenyseg
              m_tevekenyseg.each do |r|
                activity = Activity.find_or_create_by_name(r) { |act| act.name = r }
                if !megr.activities.include?(activity)
                  megr.activities << activity
                end
              end


              if !megr # hack, hogy nil id-val teegye be, mert valami nem okés a parsolt adattal
                megr = Struct.new(:id).new
              end

              contract = Contract.create( :number => c_number,
                                         :name             => c_name,
                                         :no_of_proposals => c_no_of_proposals.to_i,
                                         :buyer_id         => megr.id,
                                         :seller_id        => vall.id,
                                         :description      => c_elnevezes,
                                         :subject_and_qty  => c_targy,
                                         :sum_value        => c_sum_value,
                                         :original_sum_value  => c_original_sum_value,
                                         :s_vat_incl       => afa(c_sum_value_afa),
                                         :contracted_value => c_ertek,
                                         :original_contracted_value => c_eredeti_ertek,
                                         :c_vat_incl       => afa(c_ertek_afa),
                                         :estimated_value  => c_becsult,
                                         :e_vat_incl       => afa(c_becsult_afa),
                                         :currency         => c_currency,
                                         :notification_id  => note.id,
                                         :issued_at        => date,
                                         :case_number      => case_number,
                                         :place_of_performance => c_telj_helye

                                        )
                                        if contract
                                          c_cpv.each do |cpv|
                                            contract.cpvs << Cpv.find_or_create_by_name(cpv) { |rec| rec.name = cpv }
                                          end
                                          c_tipus.each do |type|
                                            contract.contract_types << ContractType.find_or_create_by_name(type) { |rec| rec.name = type }
                                          end
                                          c_keret.each do |frame|
                                            contract.contract_frames << ContractFrame.find_or_create_by_name(frame) { |rec| rec.name = frame }
                                          end
                                        end
                                        if !contract # hack, hogy nil id-val teegye be, mert valami nem okés a parsolt adattal
                                          contract = Struct.new(:id).new
                                        end

                                        rel = InterorgRelation.create( :value => c_ertek,
                                                                      :currency => c_currency,
                                                                      :vat_incl => afa(c_ertek_afa),
                                                                      :contract_id => contract.id,
                                                                      :o2o_relation_type_id => O2oRelationType.find_by_name(KOZBESZ_NYERTES).id,
                                                                      :organization_id => megr.id,
                                                                      :related_organization_id => vall.id,
                                                                      :notification_id  => note.id,
                                                                      :information_source_id => info.id,
                                                                      :issued_at => date,
                                                                      :name => contract.description.blank? ? contract.name : contract.description,
                                                                      :parsed => true

                                                                     )
                                                                     puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
                                                                     puts note.inspect
                                                                     puts megr.inspect
                                                                     puts vall.inspect
                                                                     puts contract.inspect
                                                                     puts rel.inspect
                                                                     puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

                                                                     # sleep 1

                                                                     puts ":: a legalacsonyabb vagy mi..."
                                                                     # legalacsonyabb 
                                                                     h = look_price_between("a legalacsonyabb ellenszolgáltatást tartalmazó ajánlat", "Valószínűsíthető", j)

                                                                     puts ":: ÁFA"
                                                                     # áfa info:
                                                                     look_x_after_between( "a legalacsonyabb ellenszolgáltatást tartalmazó ajánlat", "Valószínűsíthető", j)
                                                                     puts h.inspect
                                                                     puts commify( h[:value] )

                                                                     # ugrás a következő vállalkozóra ebben a hirdetményben
                                                                     j = get_pos("IV. szakasz", j)

            end    
          end
        end
      end
      nfo = File.open("db/kbe/#{lapid}.sum", 'w')
      nfo.puts name 
      nfo.puts "processing at #{Time.now}"
      puts    '=========== összesen ============'
      nfo.puts  '=========== összesen ============'
      puts commify( @sum )
      nfo.puts commify( @sum )
      @log.puts commify( @sum )
      @log.puts "notification id is #{note.id}, note number is #{note.number}"
      @log.puts "- - - - - -  processed #{@lines_size} lines at: #{Time.now}  - - - - - - - "
      @log.puts ""
      note.contracted_value = @sum
      note.save
      @ertekek.sort {|x,y| y[0] <=> x[0] }.each do |e| puts(e.inspect); nfo.puts(e.inspect) end
      nfo.close
    end
    @log.close
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
      kl = '/' + person.attributes['href'].value
      pe = Person.find_by_klink( kl )
      if !pe && first_name!=nil
        puts "saving person: " +  person.children[0].text
        Person.create!(:last_name => last_name, :first_name => first_name, :klink => kl, :information_source_id => info_id)
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
    (1..300).each do |i|
      puts "fetching dates on page #{i} on k-monitor.hu at " + Time.now.to_s
      articles = Nokogiri::HTML(open("http://www.k-monitor.hu/kereses?page=#{i}"))
      articles.css(".news_list_1").each do |article|
       #if article.search("input[@name='halora']").first.attributes['value'].value == "igen"
          wlink = article.css("h3 a")[0].attributes['href'].value.split('?')[0] || ""
          issue_date = article.css(".extra a")[1].text.to_textual_id.gsub('-','.').
            gsub("január","jan").
            gsub("február","feb").
            gsub("március","mar").
            gsub("május","may").
            gsub("június","jun").
            gsub("július","jul").
            gsub("augusztus","aug").
            gsub("szeptember","sep").
            gsub("október","oct").
            to_date
          internet_address = "http://www.k-monitor.hu/" + wlink
          a = Article.find_by_internet_address(internet_address) 
          x = article.search("a").last.attributes.first.last.text
          x = "http://#{x}" if x[0..6] != "http://"
          if a and !a.issued_at
            puts a.issued_at = issue_date
            a.save
          end
          if a and !a.original_internet_address
            a.original_internet_address = x 
            a.original_source = Domainatrix.parse( x ).domain
            a.save
          end
#        end
      end
    end
  end
          
   
  desc 'fetch articles from k-monitor.hu'
  task :articles => :environment do
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    f_p2p = P2pRelationType.find_by_name('sajtó')
    f_o2o = O2oRelationType.find_by_name('sajtó')
    f_o2p = O2pRelationType.find_by_name('sajtó')
    f_p2o = P2oRelationType.find_by_name('sajtó')
    articles = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/kereses'))
#    (1..articles.css("span.result")[0].children[0].text.to_i / 10 + 1).each do |i|
    (1..259).each do |i|
      puts "fetching page #{i} on k-monitor.hu at " + Time.now.to_s
      articles = Nokogiri::HTML(open("http://www.k-monitor.hu/kereses?page=#{i}"))
      articles.css(".news_list_1").each do |article|
        if article.search("input[@name='halora']").first.attributes['value'].value == "igen"
          wlink = article.css("h3 a")[0].attributes['href'].value.split('?')[0] || ""
          issue_date = article.css(".extra a")[1].text.to_textual_id.gsub('-','.').
            gsub("január","jan").
            gsub("február","feb").
            gsub("március","mar").
            gsub("május","may").
            gsub("június","jun").
            gsub("július","jul").
            gsub("augusztus","aug").
            gsub("szeptember","sep").
            gsub("október","oct").
            to_date
          puts internet_address = "http://www.k-monitor.hu/" + wlink
          a = Article.find_or_create_by_internet_address(internet_address) do |r|
            r.summary = article.css(".n_teaser")[0].children[0].text.strip
            r.name = article.css("h3 a")[0].children[0].text.strip
            r.weblink = wlink
            r.issued_at = issue_date
            r.internet_address = internet_address
          end
          x = article.search("a").last.attributes.first.last.text
          x = "http://#{x}" if x[0..6] != "http://"
          a.original_internet_address = x 
          a.original_source = Domainatrix.parse( x ).domain
          a.issued_at = issue_date
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
