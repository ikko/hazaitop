# -*- encoding : utf-8 -*-
namespace :upgrade do

  desc 'weblink, domain and host information'
  task :information_source => :environment do
    InformationSource.all.each do |p|
      p.save
    end
  end

  desc 'k-monitor articles web address upgrade'
  task :articles => :environment do
    i = InformationSource.find_by_name "k-monitor.hu"
    Article.all.each do |a|
      unless a.information_source_id
        a.information_source_id = i.id
        a.internet_address = i.web + "/" + a.weblink if a.internet_address.blank?
        a.save
      end
    end
  end

end
