# frozen_string_literal: true

require_relative "test-helper"
require "serrano/error"

class TestRandomDois < Test::Unit::TestCase
  def test_random_dois
    VCR.use_cassette("test_random_dois") do
      res = Serrano.random_dois
      assert_equal(10, res.length)
      assert_equal(Array, res.class)
      assert_equal(String, res[0].class)
    end
  end

  def test_random_dois_limit
    VCR.use_cassette("test_random_dois_limit") do
      res = Serrano.random_dois(sample: 3)
      assert_equal(3, res.length)
    end
  end

  def test_random_dois_errors
    VCR.use_cassette("test_random_dois_errors") do
      assert_raise Serrano::BadRequest do
        puts Serrano.random_dois(sample: 101)
      end
    end
  end
end
