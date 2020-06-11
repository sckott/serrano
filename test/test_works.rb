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

class TestWorks < Test::Unit::TestCase
  def setup
    @doi = "10.1371/journal.pone.0033693"
    @dois = ["10.1007/12080.1874-1746", "10.1007/10452.1573-5125", "10.1111/(issn)1442-9993"]
  end

  def test_works
    VCR.use_cassette("test_works") do
      res = Serrano.works(ids: @doi)
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
    end
    # assert_equal(200, res[0].status)
  end

  def test_works_many_dois
    VCR.use_cassette("test_works_many_dois") do
      res = Serrano.works(ids: @dois)
      assert_equal(3, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
    end
    # assert_equal(200, res[0].status)
  end

  def test_works_query
    VCR.use_cassette("test_works_query") do
      res = Serrano.works(query: "ecology")
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
    end
    # assert_equal(200, res.status)
  end

  def test_works_filter_handler
    VCR.use_cassette("test_works_filter_handler") do
      res = Serrano.works(filter: {has_funder: true, has_full_text: true})
      assert_equal(Hash, res.class)
    end
    # assert_equal(200, res.status)
  end

  def test_bad_filter_structure_raises_exception
    assert_raises(ArgumentError) do
      # Uses a string instead of a hash
      Serrano.works(filter: "has-abstract")
    end
  end

  def test_bad_filter_content_raises_exception
    assert_raises(ArgumentError) do
      # Uses an incorrect filter name
      Serrano.works(filter: {"has_nonsense" => true})
    end
  end

  def test_works_sort
    VCR.use_cassette("test_works_sort") do
      res1 = Serrano.works(query: "ecology", sort: "relevance")
      scores = res1["message"]["items"].collect { |x| x["score"] }.flatten
      res2 = Serrano.works(query: "ecology", sort: "deposited")
      deposited = res2["message"]["items"].collect { |x| x["deposited"]["date-time"] }.flatten
      assert_equal(4, res1.length)
      assert_equal(4, res2.length)
      assert_equal(Hash, res1.class)
      assert_equal(Hash, res2.class)
      assert_true(scores.max > scores.min)
      assert_true(deposited.max > deposited.min)
    end
  end

  # def test_works_order
  #   VCR.use_cassette("test_works_order") do
  #     res1 = Serrano.works(query: "ecology", sort: 'indexed', order: "asc")
  #     t1 = res1['message']['items'].collect { |x| x['indexed']['date-time'] }.flatten
  #     res2 = Serrano.works(query: "ecology", sort: 'indexed', order: "desc")
  #     t2 = res2['message']['items'].collect { |x| x['indexed']['date-time'] }.flatten
  #     assert_equal(4, res1.length)
  #     assert_equal(4, res2.length)
  #     assert_equal(Hash, res1.class)
  #     assert_equal(Hash, res2.class)
  #     assert_true(t1.last > t1[0])
  #     assert_true(t2[0] > t2.last)
  #   end
  # end

  def test_works_facet
    VCR.use_cassette("test_works_facet") do
      res = Serrano.works(facet: "license:*", limit: 0, filter: {has_full_text: true})
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      assert_equal(0, res["message"]["items"].length)
      assert_equal(1, res["message"]["facets"].length)
      assert_true(res["message"]["facets"]["license"]["values"].length > 100)
    end
  end

  def test_works_sample
    VCR.use_cassette("test_works_sample") do
      res = Serrano.works(sample: 3)
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      assert_equal(3, res["message"]["items"].length)
    end
  end

  def test_works_select
    VCR.use_cassette("test_works_select") do
      res = Serrano.works(select: %w[DOI title])
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      assert_equal(2, res["message"]["items"][0].length)
      assert_equal(%w[DOI title], res["message"]["items"][0].keys)
    end
  end
end
