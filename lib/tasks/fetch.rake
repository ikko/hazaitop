require 'nokogiri'
require 'open-uri'

namespace :fetch do
  desc 'fetch people'
  task :people => :environment do
    i = Person.count
    people = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/szemelyek'))
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    people.css(".tags_table a").each do |person|
      puts "-------------"
      puts "fetching person: " +  person.children[0].text
      name = person.children[0].text.split(' ')
      last_name = name[0]
      first_name= name[1..-1].join(' ') if name.length>1
      pe = Person.find_by_first_name_and_last_name(first_name, last_name)
      if !pe && first_name!=nil
        puts "saving person: " +  person.children[0].text
        Person.create!(:last_name => last_name, :first_name => first_name, :klink => '/' + person.attributes['href'].value, :information_source_id => info_id)
      elsif !first_name
        puts "Couldn't fetch person: #{last_name}, #{person.attributes['href'].value}"
      end
    end
    puts (Person.count - i).to_s + " people added"
  end

  desc 'fetch organizations'
  task :organizations => :environment do
    i = Organization.count
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    grade_id = OrgGrade.find_by_name("magáncég").id
    organizations = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/intezmenyek'))
    organizations.css(".tags_table a").each do |organization|
      puts "-------------"
      puts "fetching organization: " +  organization.children[0].text
      org = Organization.find_by_name(organization.children[0].text)
      if !org
        puts "saving organization: " +  organization.children[0].text
        orge = Organization.create(:name  => organization.children[0].text, :klink => '/' + organization.attributes['href'].value, :information_source_id => info_id, :org_grade_id => grade_id)
      end
    end
    puts (Organization.count - i).to_s + " organization added"
  end

  desc 'fetch article'
  task :articles => :environment do
    info_id = InformationSource.find_by_name('k-monitor.hu').id
    articles = Nokogiri::HTML(open('http://www.k-monitor.hu/adatbazis/kereses'))
    f_p2p = P2pRelationType.find_by_name('feldolgozásra vár')
    f_o2o = O2oRelationType.find_by_name('feldolgozásra vár')
    f_o2p = O2pRelationType.find_by_name('feldolgozásra vár')
    f_p2o = P2oRelationType.find_by_name('feldolgozásra vár')
    articles.css(".news_list_1").each do |article|
      wlink = article.css("h3 a")[0].attributes['href'].value
      a = Article.find_or_create_by_weblink(wlink) do |r|
        r.summary = article.css(".n_teaser")[0].children[0].text
        r.title = article.css("h3 a")[0].children[0].text
        r.weblink = wlink 
      end
      tags = []
      article.css(".links a, .links_starred a").each do |link|
        href = link.attributes['href'].value.sub("/kereses","")
        puts href

        tag = Person.find_by_klink(href) || Organization.find_by_klink(href)
        next unless tag
        tags << tag
      end
      puts tags.inspect
      tags.each do |t1|
        tags.each do |t2|
          if t1.klink != t2.klink

            if t1.kind_of?(Person) and t2.kind_of?(Person)
              puts "p2p"
              relation = InterpersonalRelation.find( :first, :conditions => [ 'person_id = ? and related_person_id = ? and information_source_id = ?', t1.id, t2.id, info_id ])
              unless relation
                relation = InterpersonalRelation.create( :person_id => t1.id, :related_person_id => t2.id, :information_source_id => info_id, :p2p_relation_type_id => f_p2p.id )
              end
              unless relation.articles.include?(a)
                relation.articles << a
              end
            end
            
            if t1.kind_of?(Organization) and t2.kind_of?(Organization)
              puts "o2o"
              relation = InterorgRelation.find( :first, :conditions => [ 'organization_id = ? and related_organization_id = ? and information_source_id = ?', t1.id, t2.id, info_id])
              unless relation
                relation = InterorgRelation.create!( :organization_id => t1.id, :related_organization_id => t2.id, :information_source_id => info_id, :o2o_relation_type_id => f_o2o.id)
              end
              unless relation.articles.include?(a)
                relation.articles << a
              end
              
            end
 
            if t1.kind_of?(Person) and t2.kind_of?(Organization)
              puts "p2o"
              relation = PersonToOrgRelation.find( :first, :conditions => [ 'person_id = ? and organization_id = ? and information_source_id = ?', t1.id, t2.id, info_id])
              unless relation
                relation = PersonToOrgRelation.create!( :person_id => t1.id, :organization_id => t2.id, :information_source_id => info_id, :p2o_relation_type_id => f_p2o.id)
              end
              unless relation.articles.include?(a)
                relation.articles << a
              end
              
            end
           
          end
        end
      end
    end
  end

end
