# frozen_string_literal: true
require_relative "test-helper"

class TestPrefixes < Test::Unit::TestCase
  def setup
    @id = "10.1016"
    @ids = ["10.1016", "10.1371", "10.1023", "10.4176", "10.1093"]
  end

  def test_prefixes
    VCR.use_cassette("test_prefixes") do
      res = Serrano.prefixes(ids: @id)
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal("prefix", res[0]["message-type"])
    end
  end

  def test_prefixes_many_ids
    VCR.use_cassette("test_prefixes_many_ids") do
      res = Serrano.prefixes(ids: @ids)
      assert_equal(5, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal("prefix", res[0]["message-type"])
      assert_equal("Elsevier BV", res[0]["message"]["name"])
    end
  end

  def test_prefixes_works
    VCR.use_cassette("test_prefixes_works") do
      res = Serrano.prefixes(ids: @id, works: true)
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
      assert_equal("work-list", res[0]["message-type"])
    end
  end

  def test_prefixes_filter_handler
    VCR.use_cassette("test_prefixes_filter_handler") do
      res = Serrano.prefixes(ids: @id, works: true, filter: {has_funder: true})
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
      assert_equal(%w[status message-type message-version message], res[0].keys)
    end
  end

  def test_prefixes_filter_handler_failure
    VCR.use_cassette("test_prefixes_filter_handler_failure") do
      exception = assert_raise(Serrano::BadRequest) { Serrano.prefixes(ids: @id, filter: {has_funder: true}) }
      assert_equal("\n   GET https://api.crossref.org/prefixes/10.1016?filter=has-funder%3Atrue\n   Status 400: This route does not support filter",
        exception.message)
    end
  end

  def test_prefixes_select
    VCR.use_cassette("test_prefixes_select") do
      res = Serrano.prefixes(ids: @id, works: true, select: %w[DOI title])
      assert_equal(4, res[0].length)
      assert_equal(Hash, res[0].class)
      assert_equal(2, res[0]["message"]["items"][0].length)
      assert_equal(%w[DOI title], res[0]["message"]["items"][0].keys)
    end
  end
end
