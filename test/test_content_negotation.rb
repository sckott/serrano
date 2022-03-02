# frozen_string_literal: true

require_relative "test-helper"

class TestCN < Test::Unit::TestCase
  include Test::Unit::Assertions

  def setup
    @id = "10.1126/science.169.3946.635"
    @ids = ["10.1484/j.rb.4.01523", "10.1186/2050-6511-14-s1-p75", "10.1016/j.jns.2015.02.034"]
  end

  def test_cn
    VCR.use_cassette("test_cn") do
      res = Serrano.content_negotiation(ids: @id)
      assert_instance_of(String, res)
      assert_match(/science/, res)
    end
  end

  def test_cn_many_ids
    VCR.use_cassette("test_cn_many_ids") do
      res = Serrano.content_negotiation(ids: @ids)
      assert_instance_of(Array, res)
      res.each { |x| assert_instance_of(String, x) }
      assert_equal(3, res.length)
      res.each { |x| assert_match(/doi/, x) }
    end
  end

  def test_cn_query
    VCR.use_cassette("test_cn_format_param") do
      res = Serrano.content_negotiation(ids: @id, format: "citeproc-json")
      assert_equal(4, res.length)
      assert_equal(Hash, res.class)
      # assert_equal(200, res.status)
    end
  end

  # def test_cn_works
  #   VCR.use_cassette("test_cn_works") do
  #     res = Serrano.content_negotiation(ids: @id, works: true)
  #     assert_equal(1, res.length)
  #     assert_equal(Array, res.class)
  #   end
  # end

  # # should fail
  # def test_cn_filter_handler
  #   VCR.use_cassette("test_cn_filter_handler") do
  #     exception = assert_raise(Serrano::BadRequest) { Serrano.content_negotiation(filter: {has_funder: true, has_full_text: true}) }
  #     assert_equal("\n   GET https://api.crossref.org/members?filter=has-funder%3Atrue%2Chas-full-text%3Atrue\n   Status 400: Filter has-full-text specified but there is no such filter for this route. Valid filters for this route are: prefix, has-public-references, reference-visibility, backfile-doi-count, current-doi-count; Filter has-funder specified but there is no such filter for this route. Valid filters for this route are: prefix, has-public-references, reference-visibility, backfile-doi-count, current-doi-count",
  #       exception.message)
  #   end
  # end

  # def test_cn_select
  #   VCR.use_cassette("test_cn_select") do
  #     res = Serrano.content_negotiation(ids: 98, works: true, select: %w[DOI title])
  #     assert_equal(4, res[0].length)
  #     assert_equal(Hash, res[0].class)
  #     assert_equal(2, res[0]["message"]["items"][0].length)
  #     assert_equal(%w[DOI title], res[0]["message"]["items"][0].keys)
  #   end
  # end
end
