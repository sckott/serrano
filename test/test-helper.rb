require 'simplecov'
SimpleCov.start do
  track_files '../lib/**/*.rb'
  add_filter '/test'
end
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "vcr"
VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
end

require "test/unit"
require "serrano"
require "fileutils"
require "json"
