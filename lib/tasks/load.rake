namespace :load do

  desc 'import org data'
  task :orgs => :environment do
    f = File.open('db/orgs.txt', 'r')
    f.each do |l|
      a = l.split(':!:')
      org = Organization.find_by_name( a[0] )
      if org
        org.klink    = a[1]
        org.street   = a[2]
        org.city     = a[3]
        org.zip_code = a[4]
        org.phone    = a[5]
        org.fax      = a[6]
        org.email_address     = a[7]
        org.internet_address  = a[8]
        org.trade_register_nr = a[9]
        org.tax_nr   = a[10]
        puts org.name
        puts org.save
      else
        puts "WARNING: cannot process: #{l}"
      end
    end
    f.close
  end

end
