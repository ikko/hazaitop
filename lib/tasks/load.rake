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
        org.tax_nr   = a[10].strip
        puts org.name
        puts org.save
      else
        puts "WARNING: cannot process: #{l}"
      end
    end
    f.close
  end


  desc 'import manual data from db/manual_#{model}.txt'
  task :person_grades => :environment do
    puts f = File.open('db/manual_person_grades.txt', 'r')
    new_p = 0; p = []; p_ids = []
    sub = false
    f.each do |l|
      l.strip!
      if !sub
        @main = PersonGrade.find_or_create_by_name(l) do |r| r.name = l end
        sub = true
      else
        a = l.split(':!:')
        a.each do |b|
          @sub = Person.find_by_name( b.strip )
          if @sub 
            if !@sun.person_grades.include?(@main)
              @sub.person_grades << @main
              puts "added that #{@sub} is #{@main}"
            end
          else
            p << @sub
            p_ids << @sub.id
            new_p += 1
          end
        end
        sub = false
        puts "- - - - - - - "
      end
    end
    puts "#{new_p} new people found: "
    puts p.join(',')
    f.close
    puts "exiting..."
  end

end
