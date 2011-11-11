namespace :save do

  desc 'export org data to  db/orgs.txt'
  task :orgs => :environment do
    f = File.open('db/orgs.txt', 'w')
    n = 0
    x = Organization.count
    Organization.all.each do |r| 
      f.puts("#{r.name}:!:#{r.klink}:!:#{r.street}:!:#{r.city}:!:#{r.zip_code}:!:#{r.phone}:!:#{r.fax}:!:#{r.email_address}:!:#{r.internet_address}:!:#{r.trade_register_nr}:!:#{r.tax_nr}")
      n += 1
      puts "saving org #{r.name[0..40]}... #{(n.to_f / x * 100).round(2)}% #{n} of #{x}"
    end
    f.close
  end

end
