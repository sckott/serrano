require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "serrano"
require 'fileutils'
require "test/unit"
require "json"

class TestLicenses < Test::Unit::TestCase

  def test_licenses
    res = Serrano.licenses()
    assert_equal(4, res.length)
    assert_equal(Hash, res.class)
    assert_equal("license-list", res['message-type'])
    assert_true(res['message']['items'].length > 100)
  end

  def test_licenses_query
    res = Serrano.licenses(query: "creative")
    assert_equal(4, res.length)
    assert_equal(Hash, res.class)
    assert_true(res['message']['items'].length < 60)
    assert_equal(MatchData, res['message']['items'][3]['URL'].match('creative').class)
  end

  def test_licenses_limit
    # limit doesn't work on this route
    res = Serrano.licenses(limit: 3);
    assert_true(res['message']['items'].length > 100)
  end
end
