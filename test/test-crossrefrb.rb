require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "textminer"
require 'fileutils'
require "test/unit"
require "oga"

class TestResponse < Test::Unit::TestCase

  def setup
    @doi = '10.5555/515151'
    @doi2 = "10.3897/phytokeys.42.7604"
    @pdf = ["http://annalsofpsychoceramics.labs.crossref.org/fulltext/10.5555/515151.pdf"]
    @xml = ["http://annalsofpsychoceramics.labs.crossref.org/fulltext/10.5555/515151.xml"]
  end

  def test_links_endpoint
    assert_equal(Textminer::Response, Textminer.links(@doi).class)
  end

  def test_doi
    assert_equal(@doi, Textminer.links(@doi).doi)
  end

  def test_pdf
    assert_equal(@pdf, Textminer.links(@doi).pdf)
  end

  def test_xml
    assert_equal(@xml, Textminer.links(@doi).xml)
  end

  def test_fetch_xml
    res = Textminer.fetch(@doi2, "xml")
    assert_equal(HTTParty::Response, res[0].class)
    assert_true(res[0].ok?)
    assert_equal(String, res[0].body.class)
    assert_equal("PhytoKeys", Oga.parse_xml(res[0].body).xpath('//journal-meta//journal-id').text)
  end

  # def test_fetch_pdf
  #   res = Textminer.fetch(@doi2, "pdf")
  #   assert_equal(HTTParty::Response, res.class)
  #   assert_true(res.ok?)
  # end

end
