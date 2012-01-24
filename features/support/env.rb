require 'spork'

Spork.prefork do
  RAILS_ENV = "test"
  CR = "\0"
  ENV["RAILS_ENV"] ||= "cucumber"

  require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
  
  require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
  require 'cucumber/rails/world'
  require 'cucumber/rails/active_record'
  require 'cucumber/web/tableish'
#  require 'factory_girl'


  require 'capybara/rails'
  require 'capybara/cucumber'
  require 'capybara/session'

  REDIS_DUMP = RAILS_ROOT + "dump.rdb"
  REDIS_DUMP_TEMP = RAILS_ROOT+"dump.rdb_temp"

#  if File.exists?(REDIS_DUMP)
#    File.rename(REDIS_DUMP, REDIS_DUMP_TEMP)
#    puts "Redis backuped"
#  end

  Capybara.default_selector = :css

  # NOTE: alapba a saját gépen tesztelünk, @facebook-al tagelt tesztek a hookban beállított hoston futnak
  # a http szükséges vmiért a chrome-nak
  Capybara.app_host = "http://www.birosag.hu"
  Capybara.default_driver = :selenium
  #Capybara.default_wait_time = 50
  Capybara.ignore_hidden_elements = true
  Hobo::Dryml.precompile_taglibs
  Capybara.server_boot_timeout = 90

  # NOTE: ez a rész kell a chrome-hoz vmiért
  class Capybara::Server
    def find_available_port
      @port = 3000
    end
  end

  # chrome böngészőben való teszteléshez
#  Capybara.register_driver :chrome do |app|
#    Capybara::Selenium::Driver.new(app, :browser => :chrome)
#  end

  puts "App host #{Capybara.app_host} in use..."
end

Spork.each_run do
  # If you set this to false, any error raised from within your app will bubble 
  # up to your step definition and out to cucumber unless you catch it somewhere
  # on the way. You can make Rails rescue errors and render error pages on a
  # per-scenario basis by tagging a scenario or feature with the @allow-rescue tag.
  #
  # If you set this to true, Rails will rescue all errors and render error
  # pages, more or less in the same way your application would behave in the
  # default production environment. It's not recommended to do this for all
  # of your scenarios, as this makes it hard to discover errors in your application.
  ActionController::Base.allow_rescue = true
  
  # If you set this to true, each scenario will run in a database transaction.
  # You can still turn off transactions on a per-scenario basis, simply tagging 
  # a feature or scenario with the @no-txn tag. If you are using Capybara,
  # tagging with @culerity or @javascript will also turn transactions off.
  #
  # If you set this to false, transactions will be off for all scenarios,
  # regardless of whether you use @no-txn or not.
  #
  # Beware that turning transactions off will leave data in your database 
  # after each scenario, which can lead to hard-to-debug failures in 
  # subsequent scenarios. If you do this, we recommend you create a Before
  # block that will explicitly put your database in a known state.
  Cucumber::Rails::World.use_transactional_fixtures = false
  # How to clean your database when transactions are turned off. See
  # http://github.com/bmabey/database_cleaner for more info.
  if defined?(ActiveRecord::Base)
    begin
      require 'database_cleaner'
      DatabaseCleaner.strategy = :truncation
    rescue LoadError => ignore_if_database_cleaner_not_present
    end
  end
# load "#{Rails.root}/test/factories.rb"
end

at_exit do
  File.rename(REDIS_DUMP_TEMP, REDIS_DUMP) if File.exists?(REDIS_DUMP_TEMP)
end
