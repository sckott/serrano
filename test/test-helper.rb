require "simplecov"
SimpleCov.start do
  track_files "../lib/**/*.rb"
  add_filter "/test"
end
if ENV["CI"] == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "vcr"
VCR.configure do |c|
  c.cassette_library_dir = "test/vcr_cassettes"
  c.hook_into :webmock
  c.filter_sensitive_data('<email>') { ENV['CROSSREF_EMAIL'] }
end

require "test/unit"
require "test/unit/assertions"
require "serrano"
require "fileutils"
require "json"
