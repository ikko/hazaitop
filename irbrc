require 'rubygems'
#require 'wirble'
#Wirble.init
#Wirble.colorize

require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 20000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-history"

require 'logger'
Object.const_set('RAILS_DEFAULT_LOGGER', Logger.new(STDOUT))

require 'awesome_print'
unless IRB.version.include?('DietRB')
  IRB::Irb.class_eval do
    def output_value
      ap @context.last_value, 
            :multiline => false,
             :plain  => false,
             :indent => 2,
             :color => {
                 :array      => :white,
                 :bignum     => :blue,
                 :class      => :yellow,
                 :date       => :greenish,
                 :falseclass => :red,
                 :fixnum     => :blue,
                 :float      => :blue,
                 :hash       => :gray,
                 :nilclass   => :red,
                 :string     => :yellowish,
                 :symbol     => :cyanish,
                 :time       => :greenish,
                 :trueclass  => :green
             }
    end
  end
else # MacRuby
  IRB.formatter = Class.new(IRB::Formatter) do
    def inspect_object(object)
      object.ai
    end
  end.new
end
