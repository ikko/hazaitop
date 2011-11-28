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

  desc "import each file info the database"
  task :import => :environment do
    n = 1
    Dir.foreach('db/copmlex/orgs') do |file|
      next if file == '.' or file == '..'
      n += 1; break if n > 2
      cegjegyzekszam = file.to_s[0..1] + '-' + file.to_s[2..3] + '-' + file.to_s[4..9]
      org = Organization.find_or_create_by_trade_register_nr( cegjegyzekszam ) do |r| r.name = cegjegyzekszam + rand(3000).to_s end
      
      f = File.open(file)
      doc = Nokogiri::XML(f)


      f.close

    end
  end

end
