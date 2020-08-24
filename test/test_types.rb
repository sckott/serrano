# frozen_string_literal: true

require_relative "test-helper"

class TestTypes < Test::Unit::TestCase
  def setup
    @id = "journal"
    @ids = %w[journal dissertation]
  end

  def test_types_no_ids
    VCR.use_cassette("test_types_no_ids") do
      res = Serrano.types
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      assert_equal("type-list", res["message-type"])
    end
  end

  def test_types_single_id
    VCR.use_cassette("test_types_single_id") do
      res = Serrano.types(ids: @id)
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal("type", res[0]["message-type"])
    end
  end

  def test_types_many_ids
    VCR.use_cassette("test_types_many_ids") do
      res = Serrano.types(ids: @ids)
      assert_equal(2, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal("type", res[0]["message-type"])
      assert_equal("journal", res[0]["message"]["id"])
    end
  end

  def test_types_select
    VCR.use_cassette("test_types_select") do
      res = Serrano.types(ids: "journal", works: true, select: %w[DOI title])
      assert_equal(4, res[0].length)
      assert_equal(Hash, res[0].class)
      assert_equal(2, res[0]["message"]["items"][0].length)
      assert_equal(%w[DOI title], res[0]["message"]["items"][0].keys)
    end
  end
end
