require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/autorun'
require 'shoulda'
require 'shoulda-context'
require 'mocha/setup'
require 'awesome_print'

#require 'statsample-timeseries'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'statsample-timeseries'
module MiniTest
  # class Unit
    class Test
    include Shoulda::Context::Assertions
    include Shoulda::Context::InstanceMethods
    extend Shoulda::Context::ClassMethods
      def self.should_with_gsl(name,&block)
        should(name) do
          if Statsample.has_gsl?
            instance_eval(&block)
          else
            skip("Requires GSL")
          end
        end
      end
    end
  # end

  module Assertions
    alias :assert_raise :assert_raises unless method_defined? :assert_raise
    alias :assert_not_equal :refute_equal unless method_defined? :assert_not_equal
    alias :assert_not_same :refute_same unless method_defined? :assert_not_same
    unless method_defined? :assert_nothing_raised
      def assert_nothing_raised(msg=nil)
        msg||="Nothing should be raised, but raised %s"
        begin
          yield
          not_raised=true
        rescue Exception => e
          not_raised=false
          msg=sprintf(msg,e)
        end
        assert(not_raised,msg)
      end
    end
  end
end

MiniTest.autorun
