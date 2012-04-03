# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'open-uri'

namespace :mvh do
  desc 'mvh import'
  task :import => :environment do



    def commify(v) 
      (s=v.to_s;x=s.length;s).rjust(x+(3-(x%3))).scan(/.{3}/).join(',').strip
    end

    # initioalize
    info = InformationSource.find_or_create_by_name("MVH") do |r|
      r.name = "MVH"
      r.web = "http://www.mvh.gov.hu"
    end
    user = User.find_or_create_by_name("Beta") do |u|
      u.name = "Beta"
      u.email_address = "beta@addig.hu"
    end


    palyaztato = Organization.find_by_name("Mezőgazdasági és Vidékfejlesztési Hivatal")
    palyazo_rel = OToORelationType.find_or_create_by_name('palyázó') do |r| r.name = 'pályázó'; r.parsed = true end
    palyaztato_rel = OToORelationType.find_or_create_by_name('palyáztató') do |r| r.name = 'pályáztató'; r.parsed = true; r.pair_id = palyazo_rel.id end
    palyazo_rel.pair_id = palyaztato_rel.id


    # reading data...

    file = File.open("db/ag2.csv")

    file.each_line do |f|
      a = f.split(';')
      next if a.size != 9
      puts 'org: ' + org  = a[0].gsub('"','').gsub('  ',' ').strip
      puts 'zip: ' + zip  = a[1].strip
      puts 'city: ' + city = a[2].strip
      puts 'utca: ' + utca = a[3].strip
      puts 'jogcim: ' + jogcim = a[4].strip
      puts 'alap: ' + alap = a[5].strip
      puts 'forrás: ' + forras = a[6].strip
      puts 'tamogatas: ' + tamogatas = a[7].strip
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

      next if org == "Név" or org == "magánszemély" or tamogatas.to_i < 0



      palyazo =    Organization.find_or_create_by_name( org ) do |o|       
        o.name = org
        o.city = city
        o.street = utca
        o.zip_code = zip
        o.information_source_id = info.id
        o.user_id = user.id
      end
      if !palyazo # hack, hogy nil id-val teegye be, mert valami nem okés a parsolt adattal
        palyazo = Struct.new(:id).new
      end

      us = org + jogcim + alap + tamogatas.to_i

      if !Tender.find_by_unique_string( us ) 

        tender = Tender.create( :applicant_id => palyazo.id,
                               :caller_id =>    palyaztato.id,
                               :found =>      alap,
                               :source => forras,
                               :name => jogcim,
                               :city => city,
                               :amount => tamogatas.to_i,
                               :currency => 'HUF',
                               :information_source_id => info.id,
                               :user_id => user.id,
                               :unique_string => us,
                               :url => 'http://www.mvh.gov.hu',
                               :decided_at => "2011.06.30".to_date # TODO
                              )


                              rel = InterorgRelation.create( :value => tender.amount,
                                                            :currency => tender.currency,
                                                            :vat_incl => nil,
                                                            :tender_id => tender.id,
                                                            :o_to_o_relation_type_id => palyazo_rel.id, 
                                                            :organization_id => palyaztato.id,
                                                            :related_organization_id => palyazo.id,
                                                            :information_source_id => info.id,
                                                            :parsed => true
                                                           )

                                                           tender.interorg_relation_id = rel.id
                                                           tender.save
                                                           puts pp(rel)
                                                           puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
                                                           puts rel.inspect
                                                           puts tender.inspect
                                                           puts palyazo.inspect
                                                           puts palyaztato.inspect
                                                           puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

      #sleep 5111
      end

    end
  end
end
