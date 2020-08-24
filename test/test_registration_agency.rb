# frozen_string_literal: true

require_relative "test-helper"
require "serrano/error"

class TestRegistrationAgency < Test::Unit::TestCase
  def test_registration_agency
    VCR.use_cassette("test_registration_agency") do
      res = Serrano.registration_agency(ids: "10.1371/journal.pone.0033693")
      assert_equal(1, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal("crossref", res[0]["message"]["agency"]["id"])
    end
  end

  def test_registration_agency_limit
    VCR.use_cassette("test_registration_agency_many") do
      res = Serrano.registration_agency(ids: ["10.1007/12080.1874-1746", "10.1007/10452.1573-5125", "10.1111/(issn)1442-9993"])
      assert_equal(3, res.length)
      assert_equal(Array, res.class)
      assert_equal(Hash, res[0].class)
      assert_equal("crossref", res[0]["message"]["agency"]["id"])
    end
  end

  def test_regist_agency_errors
    # missing param
    assert_raise ArgumentError do
      puts Serrano.registration_agency
    end

    # required keyword
    assert_raise ArgumentError do
      puts Serrano.registration_agency("asdf")
    end

    # required keyword
    VCR.use_cassette("test_registration_agency_not_found") do
      assert_raise Serrano::NotFound do
        puts Serrano.registration_agency(ids: "232234234234")
      end
    end
  end
end
