namespace :complex do

  desc 'split complex xml file to ceg xmls'
  task :slice => :environment do
    f = File.open('db/complex/data.xml', 'r')
    encoding = f.gets.strip
    if f.gets.strip == "<export>"
      f.each do |l|
        if l[0..7] == "<ceg id="
          puts @o = File.open("db/complex/orgs/#{l.strip.scan(/\d+/).first.to_i}.xml", "w")
          next
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

  def to_tax_nr s
    "#{s[0..7]}-#{s[8..8]}-#{s[9..10]}"
  end

  def to_date a
    if a.blank?
      return ""
    else
      a.to_date
    end
  rescue
    return ""
  end


  def parse_member a
    puts hatig  = to_date(a.search('mezo[@id="hatig"]').text)
    puts nev =    a.search('mezo[@id="nev"]').text
    if nev.empty?   # akkor ez person lesz
      puts is_person = true
      puts pnev  =  a.search('mezo[@id="pnev"]').text
      puts panev =  a.search('mezo[@id="panev"]').text
      puts porsz = "Magyarország"
      puts pirsz =  a.search('mezo[@id="pirsz"]').text
      puts phely =  a.search('mezo[@id="phely"]').text
      puts pteru =  a.search('mezo[@id="pteru"]').text
      puts phsz  =  a.search('mezo[@id="phsz"]').text
      if phely.empty? # akkor ő külföldi
        puts porsz =  a.search('mezo[@id="pkorsz"]').text
        puts pirsz =  a.search('mezo[@id="pkirsz"]').text
        puts phely =  a.search('mezo[@id="pkhely"]').text
        puts pteru =  a.search('mezo[@id="pkteru"]').text
        puts phsz  =  a.search('mezo[@id="pkhsz"]').text
      end
      # kézbesítési megbízott
      puts is_person = false
      puts pmnev  =  a.search('mezo[@id="pmnev"]').text
      puts pmanev =  a.search('mezo[@id="pmanev"]').text
      puts pmorsz = "Magyarország"
      puts pmirsz =  a.search('mezo[@id="pmirsz"]').text
      puts pmhely =  a.search('mezo[@id="pmhely"]').text
      puts pmteru =  a.search('mezo[@id="pmteru"]').text
      puts pmhsz  =  a.search('mezo[@id="pmhsz"]').text
      if pmhely.empty? # akkor ő külföldi
        puts pmorsz =  a.search('mezo[@id="pmkorsz"]').text
        puts pmirsz =  a.search('mezo[@id="pmkirsz"]').text
        puts pmhely =  a.search('mezo[@id="pmkhely"]').text
        puts pmteru =  a.search('mezo[@id="pmkteru"]').text
        puts pmhsz  =  a.search('mezo[@id="pmkhsz"]').text
      end
    else # amikor org
      puts cgjsz  =  a.search('mezo[@id="cgjsz"]').text  
      puts orszag =  a.search('mezo[@id="orsz"]').text 
      puts irsz   =  a.search('mezo[@id="irsz"]').text
      puts hely   =  a.search('mezo[@id="hely"]').text
      puts teru   =  a.search('mezo[@id="teru"]').text
      puts hsz    =  a.search('mezo[@id="hsz"]').text
    end
    puts tiszt  =  a.search('mezo[@id="tiszt"]').text
    puts email  =  a.search('mezo[@id="email"]').text
    puts labjegyzet = a.search('mezo[@id="labj"]').text
    puts adosz      = a.search('mezo[@id="adosz"]').text
    puts adoazon    = a.search('mezo[@id="adoazon"]').text
    puts kepve      = a.search('mezo[@id="kepve"]').text
    puts kepvo      = a.search('mezo[@id="kepvo"]').text
    puts tv         = a.search('mezo[@id="tv"]').text
    if tv 
      puts jogvk    = to_date(a.search('mezo[@id="jogvk"]'  ).text)
      puts jogvv    = to_date(a.search('mezo[@id="jogvv"]'  ).text)
      puts pcnev    = a.search('mezo[@id="pcnev"]'  ).text
      puts pcanev   = a.search('mezo[@id="pcnanev"]').text
      puts pccegj   = a.search('mezo[@id="pcnanev"]').text
      puts pcirsz   = a.search('mezo[@id="pcirsz"]' ).text
      puts pchely   = a.search('mezo[@id="pchely"]' ).text
      puts pcteru   = a.search('mezo[@id="pcteru"]' ).text
      puts pchsz    = a.search('mezo[@id="pchesz"]' ).text
      puts pckorsz  = a.search('mezo[@id="pckorsz"]').text
      puts pckirsz  = a.search('mezo[@id="pckirsz"]').text
      puts pckhely  = a.search('mezo[@id="pckhely"]').text
      puts pckteru  = a.search('mezo[@id="pckteru"]').text
      puts pckhsz   = a.search('mezo[@id="pckhsz"]' ).text
      puts mindig   = a.search('mezo[@id="mindig"]' ).text
      puts mnev     = a.search('mezo[@id="mnevig"]' ).text
      puts valtk    = to_date(a.search('mezo[@id="valtk"]'  ).text)
      puts valtv    = to_date(a.search('mezo[@id="valtv"]'  ).text)
      puts tnytsz   = a.search('mezo[@id="knytsz"]' ).text
      puts knytsz   = a.search('mezo[@id="tnytsz"]' ).text
      puts knyh     = a.search('mezo[@id="knyh"]'   ).text
      puts bkelt    = to_date(a.search('mezo[@id="bkelt"]'  ).text)
      puts tkelt    = to_date(a.search('mezo[@id="tkelt"]'  ).text)
    end
  end

  def parse_simple a, *what
    puts hattol = to_date(a.search('mezo[@id="hattol"]').text)
    puts hatig  = to_date(a.search('mezo[@id="hatig"]').text)
    result = []
    what.each do |w|
      result << a.search("mezo[@id='#{w}']").text
    end
    puts labj   = a.search("mezo[@id='labj']").text
    puts valtk  = to_date(a.search('mezo[@id="valtk"]').text)
    puts valtv  = to_date(a.search('mezo[@id="valtv"]').text)
    puts bkelt  = to_date(a.search('mezo[@id="bkelt"]').text)
    puts tkelt  = to_date(a.search('mezo[@id="tkelt"]').text)
    if result.size == 1
      return result.first
    else
      return result
    end
  end

  desc "import each file info the database"
  task :import => :environment do
    n = 1
    dirname = 'db/complex/orgs/'
    Dir.foreach( dirname ) do |file|
      next if file == '.' or file == '..'
      n += 1; break if n > 2
      puts file
      puts file.inspect
      fc = file.length == 13 ? "0" + file : file # lemarad a 0 a file elejéről, amikor 0-val kezdődik a cégjegyzékszám
      cegjegyzekszam = fc.to_s[0..1] + '-' + fc.to_s[2..3] + '-' + fc.to_s[4..9]
      org = Organization.find_or_create_by_trade_register_nr( cegjegyzekszam ) do |r| r.name = cegjegyzekszam + rand(3000).to_s end
      
      f = File.open(dirname + file)
      doc = Nokogiri::XML(f, nil, 'ISO8859-2')

      puts "- - - - - - - - - - - "
      puts org.inspect
      puts "- - - - - - - - - - - "
      puts doc.inspect
      puts "- - - - - - - - - - - "

      puts tax_nr = to_tax_nr( doc.search('//rovat[@id=0]/alrovat[@id=1]/mezo[@id="adosz"]').text )
      puts cim = doc.search('//rovat[@id=0]/alrovat[@id=1]/mezo[@id="cim"]').text
      puts irszam = cim[0..3]
      puts varos = cim.split(',').first[5..2000]
      puts utca =  cim.split(',').last.strip
      puts na =  doc.search('//rovat[@id=0]/alrovat[@id=1]/mezo[@id="nevalrovat"]').text
      puts nev = doc.search("//rovat[@id=2]/alrovat[@id='#{na}']/mezo[@id='nev']").text

      is_person = nil

      if org.tax_nr == tax_nr
        puts ". . . . . . . . . . . . . . . . . . . . company found"
        # ------- tisztségviselők -------, cégjegyzsére jogosultak
        doc.search('//rovat[@id=13]/alrovat').each do |a|
          puts "- - - - - - cégjegyzésre jogosultak - - - - - -"
          parse_member a
        end
        doc.search('//rovat[@id=14]/alrovat').each do |a|
          puts "- - - - - - könyvvizsgálók - - - - - -"
          parse_member a
        end
        doc.search('//rovat[@id=15]/alrovat').each do |a|
          puts "- - - - - - Felügyelő bizottsági tagok adatai - - - - - -"
          parse_member a
        end
        doc.search('//rovat[@id=16]/alrovat').each do |a|
          puts "- - - - - - Jogelődök - - - - - -"
          parse_member a
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
