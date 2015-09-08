# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crossrefrb/version'

Gem::Specification.new do |s|
  s.name        = 'crossrefrb'
  s.version     = Crossref::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2015-09-07'
  s.summary     = "Crossref Client"
  s.description = "Low Level Ruby Client for the Crossref Search API"
  s.authors     = "Scott Chamberlain"
  s.email       = 'myrmecocystus@gmail.com'
  s.homepage    = 'http://github.com/sckott/crossrefrb'
  s.licenses    = 'MIT'

  s.files = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  s.test_files  = ["test/test-crossrefrb.rb"]
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", '~> 1.6'
  s.add_development_dependency "rake", '~> 10.4'
  s.add_development_dependency "test-unit", '~> 3.1'
  s.add_development_dependency "oga", '~> 1.2'
  s.add_development_dependency "simplecov", '~> 0.10'
  s.add_development_dependency "codecov", '~> 0.1'

  s.add_runtime_dependency 'httparty', '~> 0.13'
  s.add_runtime_dependency 'thor', '~> 0.19'
  s.add_runtime_dependency 'json', '~> 1.8'
end
