# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'open-uri'

namespace :fetch2 do

  desc 'fetch onkormányzatok'
  task :onkori => :environment do
    info = InformationSource.find_or_create_by_name('valasztas.hu') do |r|
      r.name = 'valasztas.hu'
      r.web = "http://www.valasztas.hu"
    end
    user = User.find_or_create_by_name("Beta") do |u|
      u.name = "Beta"
      u.email_address = "beta@addig.hu"
    end
    kepv_rel = P2oRelationType.find_or_create_by_name('önkormányzati képviselő') do |r|
      r.name = 'önkormányzati képviselő'
    end
    testulettars = P2pRelationType.find_or_create_by_name("önkorm. képviselőtestület tagja") do |r|
      r.name ="önkorm. képviselőtestület tagok"
    end
    kepv_rel.update_attribute :p2p_relation_type_id, testulettars.id
    polg_rel = P2oRelationType.find_or_create_by_name('polgármester') do |r|
      r.name = 'polgármester'
    end
    part_rel = P2oRelationType.find_by_name('párttag')
    Dir.foreach( 'db/onkorm/files' ) do |file|
      next if file == '.' or file == '..'
      puts "=============================="
      puts file
      f = File.open( "db/onkorm/files/#{file}", 'r' )
      next if File.exists?("db/onkorm/files/#{file}.log")
      doc = Nokogiri::HTML(f)
      puts n = doc.css('td')[5].children.children.children[7].text.to_i
      puts telepules = doc.css('h1')[0].text.split(' települési választás eredményei')[0]
      puts polg_name = doc.css('table p')[1].children.children.first.children.first.text
      puts polg_part = doc.css('table p')[1].children.children.first.children.last.text
      part = Organization.find_or_create_by_name(polg_part) do |r|
        r.name = polg_part
        r.information_source_id = info.id
        r.user_id = user.id
      end if polg_part != 'FÜGGETLEN'
      t = Organization.find_or_create_by_name(telepules + " Önkormányzata") do |r|
        r.name = telepules + " Önkormányzata"
        r.city = telepules
        r.information_source_id = info.id
        r.user_id = user.id
      end
      p = Person.create!( :name => polg_name,
                          :information_source_id => info.id,
                          :user_id => user.id
                        )



      PersonToOrgRelation.create!( :person_id => p.id,
                                   :organization_id => part.id,
                                   :p2o_relation_type_id => part_rel.id,
                                   :information_source_id => info.id,
                                   :parsed => true,
                                   :start_time => "2010.10.03".to_date,
                                   :end_time =>   "2014.10.03".to_date
                                 ) if polg_part != 'FÜGGETLEN'
      PersonToOrgRelation.create!( :person_id => p.id,
                                   :organization_id => t.id,
                                   :p2o_relation_type_id => polg_rel.id,
                                   :information_source_id => info.id,
                                   :parsed => true,
                                   :start_time => "2010.10.03".to_date,
                                   :end_time =>   "2014.10.03".to_date
                                 )
      n.times do |i|
        puts kepv_name = doc.css('td')[8+i*3].text
        puts kepv_part = doc.css('td')[8+i*3+1].text.strip
        part = Organization.find_or_create_by_name(kepv_part) do |r|
          r.name = kepv_part
          r.information_source_id = info.id
          r.user_id = user.id
        end if kepv_part != 'FÜGGETLEN'
        kepviselo = Person.create!( :name => kepv_name,
                                    :information_source_id => info.id,
                                    :user_id => user.id
                                  )
        PersonToOrgRelation.create!( :person_id => kepviselo.id,
                                     :organization_id => part.id,
                                     :p2o_relation_type_id => part_rel.id,
                                     :information_source_id => info.id,
                                     :parsed => true,
                                     :start_time => "2010.10.03".to_date,
                                     :end_time =>   "2014.10.03".to_date
                                   ) if kepv_part != 'FÜGGETLEN'
        PersonToOrgRelation.create!( :person_id => kepviselo.id,
                                     :organization_id => t.id,
                                     :p2o_relation_type_id => kepv_rel.id,
                                     :information_source_id => info.id,
                                     :parsed => true,
                                     :start_time => "2010.10.03".to_date,
                                     :end_time =>   "2014.10.03".to_date
                                   )
      end
      g = File.open("db/onkorm/files/#{file}.log", 'w' )
      g.puts(Time.now.to_s)
      g.close
      break
    end
  end


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
end
