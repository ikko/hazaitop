require 'nokogiri'

namespace :asz do
  desc 'asz'
  task :get => :environment do
forwarding = true
    Organization.all.each do |org|
#      org = Organization.last
#      org = Organization.find(334)
      puts "starting to get..."
      puts org.id
      puts org.name
      puts "forwarding........................................................" if forwarding
      forwarding = false if org.id == 4993
      next if forwarding 
      system "wget -q -O tmp/orgs/#{org.id}.html \"http://jab.complex.hu/search.php?intsearchtext=#{org.name.gsub('"','').gsub(' ', '+')}&dosearch=1&page=1\""
      b = Nokogiri::HTML(open("tmp/orgs/#{org.id}.html").read, nil, 'utf-8')
      if b.css('.azoszov').text.split('Asz:')[1]
        puts "saving..."
        puts adoszam = b.css('.azoszov').text.split('Asz:')[1].split('.')[0].strip
        puts cj = b.css('.jszcim').text.split('Cg. ')[1].split(')')[0].strip
        puts(org.zip_code = b.css('.azoszov').text.split('Asz:')[0].split(' ')[0])  unless org.zip_code
        puts(org.city = b.css('.azoszov').text.split('Asz:')[0].split(' ')[1].split(',')[0])  unless org.city
        puts(org.street = b.css('.azoszov').text.split('Asz:')[0].split(',')[1].try.strip)  unless org.street
        org.tax_nr = adoszam[0..12] 
        org.trade_register_nr = cj
        org.save
      else
        puts "skipping, not found..."
      end
      puts "=============="
    end

  end
end
