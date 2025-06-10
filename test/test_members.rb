# frozen_string_literal: true

require_relative "test-helper"

class TestMembers < Test::Unit::TestCase
  def setup
    @id = 98
    @ids = [98, 340, 45]
  end

  def test_members
    VCR.use_cassette("test_members") do
      res = Serrano.members(ids: @id)
      assert_equal(1, res.length)
      # assert_equal(Array, res.class)
      # assert_equal(Hash, res[0].class)
      # assert_equal(200, res[0].status)
    end
  end

  def test_members_many_ids
    VCR.use_cassette("test_members_many_ids") do
      res = Serrano.members(ids: @ids)
      assert_equal(3, res.length)
      # assert_equal(Array, res.class)
      # assert_equal(Hash, res[0].class)
      # assert_equal(200, res[0].status)
    end
  end

  def test_members_query
    VCR.use_cassette("test_members_query") do
      res = Serrano.members(query: "ecology")
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      # assert_equal(200, res.status)
    end
  end

  def test_members_works
    VCR.use_cassette("test_members_works") do
      res = Serrano.members(ids: @id, works: true)
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
    end
  end

  # should fail
  def test_members_filter_handler
    VCR.use_cassette("test_members_filter_handler") do
      exception = assert_raise(Serrano::BadRequest) { Serrano.members(filter: {has_funder: true, has_full_text: true}) }
      assert_equal("\n   GET https://api.crossref.org/members?filter=has-funder%3Atrue%2Chas-full-text%3Atrue\n   Status 400: Filter has-full-text specified but there is no such filter for this route. Valid filters for this route are: prefix, backfile-doi-count, current-doi-count; Filter has-funder specified but there is no such filter for this route. Valid filters for this route are: prefix, backfile-doi-count, current-doi-count",
        exception.message)
    end
  end

  def test_members_select
    VCR.use_cassette("test_members_select") do
      res = Serrano.members(ids: 98, works: true, select: %w[DOI title])
      assert_equal(4, res[0].length)
      assert_equal(Hash, res[0].class)
      assert_equal(2, res[0]["message"]["items"][0].length)
      assert_equal(%w[DOI title], res[0]["message"]["items"][0].keys)
    end
  end
end
