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

