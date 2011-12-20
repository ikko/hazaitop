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
    puts @info = InformationSource.find_by_name('ahalo.hu')
    f.each do |l|
      l.strip!
      if !sub
        @main = PersonGrade.find_or_create_by_name(l) do |r| r.name = l end
        sub = true
      else
        a = l.split(':+:')
        a.each do |b|
          c = b.split(':!:')
          @sub = Person.find_or_create_by_name( c[0].strip.gsub(',','' ) ) do |w|
            w.first_name = c[1]
            w.last_name  = c[2]
            w.klink      = c[6]
            w.born_at    = c[7].try.to_date
            w.mothers_name=c[8]
            w.information_source_id = @info.id
          end
          if @sub 
            if !@sub.person_grades.include?(@main)
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
