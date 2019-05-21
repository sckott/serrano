# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'serrano'
require 'fileutils'
require 'test/unit'
require 'json'
require_relative 'test-helper'

class TestLicenses < Test::Unit::TestCase
  def test_licenses
    VCR.use_cassette('test_licenses') do
      res = Serrano.licenses
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      assert_equal('license-list', res['message-type'])
      assert_true(res['message']['items'].length > 100)
    end
  end

  def test_licenses_query
    VCR.use_cassette('test_licenses_query') do
      res = Serrano.licenses(query: 'creative')
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      assert_true(res['message']['items'].length < 60)
      assert_equal(MatchData, res['message']['items'][3]['URL'].match('creative').class)
    end
  end

  def test_licenses_limit
    # limit doesn't work on this route
    VCR.use_cassette('test_licenses_limit') do
      res = Serrano.licenses(limit: 3)
      assert_true(res['message']['items'].length > 100)
    end
  end
end
