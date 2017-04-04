require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "serrano"
require "serrano/error"
require 'fileutils'
require "test/unit"
require "json"

sleep(1)

class TestRandomDois < Test::Unit::TestCase

  def test_random_dois
    res = Serrano.random_dois()
    assert_equal(10, res.length)
    assert_equal(Array, res.class)
    assert_equal(String, res[0].class)
  end

  def test_random_dois_limit
    res = Serrano.random_dois(sample: 3)
    assert_equal(3, res.length)
  end

  def test_random_dois_errors
    assert_raise Serrano::BadRequest do
      puts Serrano.random_dois(sample: 101)
    end
  end
end
