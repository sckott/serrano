# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serrano/version'

Gem::Specification.new do |s|
  s.name        = 'serrano'
  s.version     = Serrano::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0'
  s.date        = '2015-11-04'
  s.summary     = "Crossref Client"
  s.description = "Low Level Ruby Client for the Crossref Search API"
  s.authors     = "Scott Chamberlain"
  s.email       = 'myrmecocystus@gmail.com'
  s.homepage    = 'http://github.com/sckott/serrano'
  s.licenses    = 'MIT'

  s.files = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ["lib"]

  s.bindir      = 'bin'
  s.executables = ['serrano']

  s.add_development_dependency "bundler", '~> 1.6'
  s.add_development_dependency "rake", '~> 10.4'
  s.add_development_dependency "test-unit", '~> 3.1'
  s.add_development_dependency "simplecov", '~> 0.10'
  s.add_development_dependency "codecov", '~> 0.1'
  s.add_development_dependency 'json', '~> 1.8', '>= 1.8.3'

  s.add_runtime_dependency 'faraday', '~> 0.9.1'
  s.add_runtime_dependency 'faraday_middleware', '~> 0.10.0'
  s.add_runtime_dependency 'thor', '~> 0.19'
  s.add_runtime_dependency 'multi_json', '~> 1.0'
  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.6.2'
  s.add_runtime_dependency 'uuidtools', '~> 2.1', '>= 2.1.5'
end
