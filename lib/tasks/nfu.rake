require 'nokogiri'
require 'open-uri'

namespace :nfu do
  desc 'nfu fetch'
  task :fetch => :environment do


    def commify(v) 
      (s=v.to_s;x=s.length;s).rjust(x+(3-(x%3))).scan(/.{3}/).join(',').strip
    end

    # initioalize
    info = InformationSource.find_or_create_by_name("NFÜ") do |r|
      r.name = "NFÜ"
      r.web = "http://www.nfu.hu"
    end
    user = User.find_or_create_by_name("Beta") do |u|
      u.name = "Beta"
      u.email_address = "beta@addig.hu"
    end


                palyaztato = Organization.find_by_name("Nemzeti Fejlesztési Ügynökség")
    palyazo_rel = O2oRelationType.find_or_create_by_name('palyázó') do |r| r.name = 'pályázó' end
    palyaztato_rel = O2oRelationType.find_or_create_by_name('palyáztató') do |r| r.name = 'pályáztató' end
    

    # reading data...
    # for lapid in 326220..326230 do
#    for lapid in 1..15 do
    lapid = 1
      # 282615 a vége
      puts lapid
      system "wget -O tmp/tmp.html --cookies=on --keep-session-cookies --save-cookies=cookie.txt \"http://emir.nfu.hu/kulso/jelek/index.php?i_6=104&checked_array=104&view=list&id=14&menu=104&ttipus=&tkod=&op_nev=&op_nev_teljes=&id_paly_altip=&kedv=\""
      system "wget -O tmp/nfu#{lapid}.html --cookies=on --load-cookies=cookie.txt --keep-session-cookies \"http://emir.nfu.hu/kulso/jelek/index.php?i_6=104&pn=#{lapid}&checked_array=104&view=list&id=14&menu=104&ttipus=&tkod=&op_nev=&op_nev_teljes=&id_paly_altip=&kedv=\""
      nfu = Nokogiri::HTML(open("tmp/nfu#{lapid}.html").read, nil, 'utf-8')
      puts "======================================================"
      nfu.css('.report_table tr').each do |row|
        puts osszeg = row.css('td').last.text
        next if osszeg == "Megítélt támogatás (Ft):"
        puts palyazo = row.css('td').first.elements[2].elements[0].text
        puts link = row.css('td').first.elements[2].attributes.first.last.to_s  # ez csaka vége, emir kell elé
        puts targy = row.css('td').first.elements[2].children.to_s.split('<br>').last
        puts palyazat = row.css('td').children.first.to_s

        detail = Nokogiri::HTML(open("http://emir.nfu.hu/kulso/jelek/#{link}").read, nil, 'utf-8').css('.td_adat_2')

        puts onkorm  = detail[0].text
        puts project = detail[1].text
        puts op_name = detail[2].text
        puts tender_name = detail[3].text
        puts region =  detail[4].text
        puts county =  detail[5].text 
        puts city   =  detail[6].text 
        puts amount =  detail[7].text
        puts subsidy = detail[8].text
        puts decided_at = detail[9].text
        puts decision_score = detail[10].text
        puts "-----------------------------------------------------------------"

        us = onkorm + op_name + tender_name + decided_at.to_s + amount.to_s

        if !Tender.find_by_unique_string( us )
  
                palyazo =    Organization.find_or_create_by_name( onkorm ) do |o|
                                              o.name = onkorm
                                              o.information_source_id = info.id
                                              o.user_id = user.id
                end
                if !palyazo # hack, hogy nil id-val teegye be, mert valami nem okés a parsolt adattal
                  palyazo = Struct.new(:id).new
                end

                tender = Tender.new( :applicant_id => palyazo.id,
                                     :caller_id =>    palyaztato.id,
                                     :project =>      project,
                                     :op_name => op_name,
                                     :name => tender_name,
                                     :region => region,
                                     :county => county,
                                     :city => city,
                                     :amount => amount.scan(/[0-9]/).join.to_i,
                                     :currency => (amount[-1..-2] == "Ft" ? "HUF" : nil ),
                                     :decision_score => decision_score.gsub(',','.').to_f,
                                     :decided_at => decided_at.to_date,
                                     :information_source_id => info.id,
                                     :user_id => user.id,
                                     :unique_string => us
                                   )

                                   puts "!!!!!!!!!!!!!!!!!!!!!!!!"
                                   puts pp(tender)
                                   puts "/=////////////////////=/"


                                   rel = InterorgRelation.new( :value => tender.amount,
                                                                          :currency => tender.currency,
                                                                          :vat_incl => nil,
                                                                          :tender_id => tender.id,
                                                                          :o2o_relation_type_id => palyazo_rel.id, 
                                                                          :organization_id => palyaztato.id,
                                                                          :related_organization_id => palyazo.id,
                                                                          :information_source_id => info.id
                                                                       )
                              tender.interorg_relation_id = rel.id
#                              tender.save
                              puts pp(rel)
                 puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
                                                                         puts rel.inspect
                                                                         puts tender.inspect
                                                                         puts palyazo.inspect
                                                                         puts palyaztato.inspect
                 puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

                                                                         sleep 1
        end
    end
  end
end

