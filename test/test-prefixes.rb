require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "serrano"
require 'fileutils'
require "test/unit"
require "json"

class TestPrefixes < Test::Unit::TestCase

  def setup
    @id = "10.1016"
    @ids = ['10.1016','10.1371','10.1023','10.4176','10.1093']
  end

  def test_prefixes
    res = Serrano.prefixes(ids: @id)
    assert_equal(1, res.length)
    assert_equal(Array, res.class)
    assert_equal(Hash, res[0].class)
    assert_equal("prefix", res[0]['message-type'])
  end

  def test_prefixes_many_ids
    res = Serrano.prefixes(ids: @ids)
    assert_equal(5, res.length)
    assert_equal(Array, res.class)
    assert_equal(Hash, res[0].class)
    assert_equal("prefix", res[0]['message-type'])
    assert_equal("Elsevier BV", res[0]['message']['name'])
  end

  def test_prefixes_works
    res = Serrano.prefixes(ids: @id, works: true)
    assert_equal(1, res.length)
    assert_equal(Array, res.class)
    assert_equal("work-list", res[0]['message-type'])
  end

  def test_prefixes_filter_handler
    res = Serrano.prefixes(ids: @id, works: true, filter: {has_funder: true})
    assert_equal(1, res.length)
    assert_equal(Array, res.class)
    assert_equal(["status", "message-type", "message-version", "message"], res[0].keys)
  end

  def test_prefixes_filter_handler_failure
    exception = assert_raise(Serrano::BadRequest) {Serrano.prefixes(ids: @id, filter: {has_funder: true})}
    assert_equal("\n   GET https://api.crossref.org/prefixes/10.1016?filter=has-funder%3Atrue\n   Status 400: This route does not support filter",
      exception.message)
  end

end
