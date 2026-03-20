require "vcr"
require "webmock"

VCR.configure do |c|
  c.cassette_library_dir = "test/vcr_cassettes"
  c.hook_into :webmock
  c.filter_sensitive_data("<email>") { ENV["CROSSREF_EMAIL"] }
end

if ENV["DISABLE_VCR"]
  VCR.turn_off!(ignore_cassettes: true)
  WebMock.allow_net_connect!
end

require "test/unit"
require "test/unit/assertions"
require "serrano"
require "fileutils"
require "json"
