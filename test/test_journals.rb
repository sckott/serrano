# frozen_string_literal: true

require "simplecov"
SimpleCov.start
if ENV["CI"] == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "serrano"
require "fileutils"
require "test/unit"
require "json"
require_relative "test-helper"

class TestJournals < Test::Unit::TestCase
  def setup
    @id = "2167-8359"
    @ids = %w[1803-2427 2326-4225]
  end

  def test_journals
    VCR.use_cassette("test_journals") do
      res = Serrano.journals(ids: @id)
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal("journal", res[0]["message-type"])
    end
  end

  def test_journals_many_dois
    VCR.use_cassette("test_journals_many_dois") do
      res = Serrano.journals(ids: @ids)
      assert_equal(2, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal("journal", res[0]["message-type"])
      assert_equal("journal", res[1]["message-type"])
    end
  end

  def test_journals_query
    VCR.use_cassette("test_journals_query") do
      res = Serrano.journals(query: "ecology")
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      assert_equal("journal-list", res["message-type"])
      assert_equal(String, res["message"]["items"][0]["title"].class)
    end
  end

  def test_journals_filter_handler
    VCR.use_cassette("test_journals_filter_handler") do
      exception = assert_raise(Serrano::BadRequest) { Serrano.journals(ids: "2167-8359", works: false, filter: {from_pub_date: "2014-03-03"}) }
      assert_equal("\n   GET https://api.crossref.org/journals/2167-8359?filter=from-pub-date%3A2014-03-03\n   Status 400: This route does not support filter",
        exception.message)
    end
  end

  def test_journals_select
    VCR.use_cassette("test_journals_select") do
      res = Serrano.journals(ids: "2167-8359", works: true, select: %w[DOI title])
      assert_equal(4, res[0].length)
      assert_equal(Hash, res[0].class)
      assert_equal(2, res[0]["message"]["items"][0].length)
      assert_equal(%w[DOI title], res[0]["message"]["items"][0].keys)
    end
  end
end
