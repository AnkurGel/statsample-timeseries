# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'statsample-timeseries/version'

Gem::Specification.new do |spec|
  spec.name          = 'statsample-timeseries'
  spec.version       = Statsample::TimeSeries::VERSION
  spec.authors       = ['Ankur Goel']
  spec.email         = ['']
  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = ''
  spec.license       = 'BSD-2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'statsample', '1.2.0'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'cucumber', '>= 0'
  spec.add_development_dependency 'minitest', '~> 4.7'
  spec.add_development_dependency 'mocha', '~> 0.14'
  spec.add_development_dependency 'rdoc', '~> 3.12'
  spec.add_development_dependency 'shoulda', '>= 0'
end
