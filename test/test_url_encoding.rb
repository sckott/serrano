# frozen_string_literal: true

require_relative "test-helper"

class TestUrlEncoding < Test::Unit::TestCase
  def setup
    @normal = "10.1371/journal.pone.0033693"
    @needs_encoding = "10.1002/1096-9861(20010212)430:3<283::aid-cne1031>3.0.co;2-v"
    @many_dois = ["10.1007/12080.1874-1746", "10.1007/10452.1573-5125", @needs_encoding]
  end

  def test_url_encoding
    VCR.use_cassette("test_url_encoding") do
      res = Serrano.works(ids: @needs_encoding)
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal(@needs_encoding, res[0]["message"]["DOI"])
    end
  end

  def test_url_encoding_many
    VCR.use_cassette("test_url_encoding_many") do
      res = Serrano.works(ids: @many_dois)
      assert_equal(3, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[2].class)
      assert_equal(@many_dois[0], res[0]["message"]["DOI"])
      assert_equal(@many_dois[1], res[1]["message"]["DOI"])
      assert_equal(@many_dois[2], res[2]["message"]["DOI"])
    end
  end

  def test_url_encoding_content_negotiation
    VCR.use_cassette("test_url_encoding_content_negotiation") do
      res = Serrano.content_negotiation(ids: @many_dois)
      assert_equal(3, res.length)
      assert_equal(Array, res.class)
      assert_equal(String, res[2].class)
      assert_match(@many_dois[2], res[2])
    end
  end
end
