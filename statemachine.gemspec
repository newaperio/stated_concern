# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stated_concern/version'

Gem::Specification.new do |spec|
  spec.name          = 'stated_concern'
  spec.version       = StatedConcern::VERSION
  spec.authors       = ['Logan Leger']
  spec.email         = ['logan@loganleger.com']
  spec.description   = 'Does state stuff'
  spec.summary       = 'Does some stuff with states'
  spec.homepage      = 'https://github.com/newaperio/stated_concern'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '~> 4.0.0'
  spec.add_runtime_dependency 'activesupport', '~> 4.0.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'sqlite3'
end
