# encoding: utf-8
require 'rake'
require 'bundler/gem_tasks'

# Setup the necessary gems, specified in the gemspec.
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

desc "Open IRB with statsample-timeseries loaded."
task :console do
  require 'irb'
  require 'irb/completion'
  $:.unshift File.expand_path("../lib", __FILE__)
  require 'statsample-timeseries'
  ARGV.clear
  IRB.start
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = Statsample::TimeSeries::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "statsample-timeseries #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
