# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'statsample-timeseries/version'

Gem::Specification.new do |spec|
  spec.name          = 'statsample-timeseries'
  spec.version       = Statsample::TimeSeries::VERSION
  spec.authors       = ['Ankur Goel', 'Sameer Deshmukh']
  spec.email         = ['sameer.deshmukh93@gmail.com']
  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = ''
  spec.license       = 'BSD-2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'statsample', '2.0.0'
  spec.add_runtime_dependency 'daru', '~> 0.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rb-gsl', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'minitest', '~> 5.7'
  spec.add_development_dependency 'mocha', '~> 1.1'
  spec.add_development_dependency 'shoulda', '~> 3.5'
  spec.add_development_dependency 'awesome_print'
end
