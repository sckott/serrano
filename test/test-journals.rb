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

class TestJournals < Test::Unit::TestCase

  def setup
    @id = "2167-8359"
    @ids = ['1803-2427', '2326-4225']
  end

  def test_journals
    res = Serrano.journals(ids: @id)
    assert_equal(1, res.length)
    assert_equal(Array, res.class)
    assert_equal(Hash, res[0].class)
    assert_equal("journal", res[0]['message-type'])
  end

  def test_journals_many_dois
    res = Serrano.journals(ids: @ids)
    assert_equal(2, res.length)
    assert_equal(Array, res.class)
    assert_equal(Hash, res[0].class)
    assert_equal("journal", res[0]['message-type'])
    assert_equal("journal", res[1]['message-type'])
  end

  def test_journals_query
    res = Serrano.journals(query: "ecology")
    assert_equal(4, res.length)
    assert_equal(Hash, res.class)
    assert_equal("journal-list", res['message-type'])
    assert_equal(String, res['message']['items'][0]['title'].class)
  end

  def test_journals_filter_handler
    res = Serrano.journals(ids: "2167-8359", works: false, filter: {from_pub_date: '2014-03-03'})
    assert_equal(Array, res.class)
    assert_equal("validation-failure", res[0]['message-type'])
    assert_equal("parameter-not-allowed", res[0]['message'][0]['type'])
  end

end
