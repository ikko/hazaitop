require "socket"
#require "yajl/json_gem"
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

=begin
Before("@facebook") do |scenario|
  Capybara.app_host = "http://apps.facebook.com/#{RestGraph.default_canvas}"
  # töröljük az adatbázist
  $REAL_ACTOR_SOCKET = TCPSocket.new(CustomConstant::REAL_ACTOR_SERVER, '5001') unless $REAL_ACTOR_SOCKET
  $REAL_ACTOR_SOCKET.print({:action => "truncate"}.to_json + CR)
  $REAL_ACTOR_SOCKET.flush
  if scenario.source_tag_names.include?('@seed') && $REAL_ACTOR_SOCKET.readline(CR)
    $REAL_ACTOR_SOCKET.print({:action => "internal_request", :params => {:get_request => :setting_generate}}.to_json + CR)
  end
end

Before("@facebook_login") do 
  ENV["IFINDEYE_FACEBOOK"] = "yes"
end
=end
Before do |scenario|
#  $REAL_ACTOR_SOCKET = TCPSocket.new(CustomConstant::REAL_ACTOR_SERVER, '5001')

  # alapjáraton kevés idővel dolgozunk képfeltöltésnél
  $PICTURE_UPLOAD_TIME = 0.05

  # üzenet küldési idők teszteléséhez
  $SEND_TIME = []

  # beállítjuk hogy alapban nincs manuálisan elinduló rake task
  $STOP_RAKE_JOB = false
  # adatbázis feltöltése a szükséges adatokkal
  Rake::Task["db:seed"].reenable
  Rake::Task["db:seed"].invoke

#  connect_to_s3
  # test bucket törlése, kivéve az asseteket amiket újra felhasználunk ha szükséges
 # AWS::S3::Bucket.objects('ifindeye-tests').reject {|o| o.key =~ /assets/ || o.key =~ /processing.html/}.each do |s3_object|
 #   AWS::S3::S3Object.delete(s3_object.key, 'ifindeye-tests')
 # end
  # NOTE: ezt csak akkor használjuk újra ha az assets vmiért már nem fog kelleni
  # AWS::S3::Bucket.find('ifindeye-tests').delete_all

  # redisből mindent törlünk, kivéve a futó real-actor szerverek címeit
#  REDIS.keys.each do |key|
#    REDIS.del(key) unless key == 'real_actors'
#  end

  # NOTE: capybara edge tartalmazza ezt
  # majd kivenni ha a most használt 0.4.1.2-esnél újabb verzió lesz kint belőle
  scenario.source_tag_names.each do |tag|
    driver_name = tag.sub(/^@/, '').to_sym
    if Capybara.drivers.has_key?(driver_name)
      Capybara.current_driver = driver_name
    end
  end

  $DEFAULT_SESSION = Capybara.current_session
end

# http://jorgemanrubia.net/2010/09/01/using-delayed_job-with-cucumber/
Before('@dj') do |scenario|
  Delayed::Job.delete_all
  if scenario.source_tag_names.include? "@no_s3_con"
    system "/usr/bin/env RAILS_ENV=test NO_S3_CON=true rake jobs:work &"
  else
    system "/usr/bin/env RAILS_ENV=test rake jobs:work &"
  end
end

Before('@send_subscribe_notification') do |scenario|
  system "/usr/bin/env RAILS_ENV=test rake real_actor:send_subscribe_notification &"
end

Before('@send_queued_subscribe_notification') do
  system "/usr/bin/env RAILS_ENV=test rake real_actor:send_queued_subscribe_notification &"
end

After('@send_message_notification') do
  system "ps -ef | grep 'rake real_actor:send_message_notification' | grep -v grep | awk '{print $2}' | xargs kill -9"
end

After('@send_subscribe_notification') do
  system "ps -ef | grep 'rake real_actor:send_subscribe_notification' | grep -v grep | awk '{print $2}' | xargs kill -9"
  # ha netán létrehoznánk emaileket a job közben akkor a teszt végén töröljük
  File.delete('tmp/mails') if File.exists?('tmp/mails')
end

After('@send_queued_subscribe_notification') do
  system "ps -ef | grep 'rake real_actor:send_queued_subscribe_notification' | grep -v grep | awk '{print $2}' | xargs kill -9"
end

After('@dj,@stop_dj') do
  system "ps -ef | grep 'rake jobs:work' | grep -v grep | awk '{print $2}' | xargs kill -9"
  # ha netán létrehoznánk emaileket a job közben akkor a teszt végén töröljük
  File.delete('tmp/mails') if File.exists?('tmp/mails')
end

After('@site_close') do
  require 'ftools'
  File.copy(Rails.root + "public/opened.html", Rails.root + "public/index.html")
end

After('@ruby_console') do
  $CONSOLE_STDIN.close
  $CONSOLE_STDOUT.close
  $CONSOLE_STDERR.close
  File.delete('tmp/mails') if File.exists?('tmp/mails')
end

Before('@real_upload') do
  $REAL_UPLOAD = true 
end

# ha nem akarjuk kilőni teszt végén a browsert
Before("@dont_close") do
  class ::Capybara::Driver::Selenium
    def browser
      @browser ||= Selenium::WebDriver.for(options[:browser] || :firefox, options.reject{|key,val| key == :browser})
    end
  end
end

After('@dont_close') do
  class ::Capybara::Driver::Selenium
    def browser
      unless @browser
        @browser = Selenium::WebDriver.for(options[:browser] || :firefox, options.reject{|key,val| key == :browser})
        at_exit do
          @browser.quit
        end
      end
      @browser
    end
  end
end

# mivel amikor updateli az eye modelt akkor újra kapcsolódik
AfterStep('@no_s3_con') do
  AWS::S3::Base.disconnect!
end

Before("@no_s3_con") do
  $TEST_BUCKET_ENV = 'no_connection'
end

After do
  $REAL_ACTOR_SOCKET.close
  $REAL_ACTOR_SOCKET = nil
  $TEST_BUCKET_ENV = nil
  $REAL_UPLOAD = nil
  ENV["IFINDEYE_FACEBOOK"] = nil
  if $STOP_RAKE_TASK
    system "ps -ef | grep 'rake #{$STOP_RAKE_JOB}' | grep -v grep | awk '{print $2}' | xargs kill -9"
    # ha netán létrehoznánk emaileket a job közben akkor a teszt végén töröljük
    File.delete('tmp/mails') if File.exists?('tmp/mails')
  end
end
