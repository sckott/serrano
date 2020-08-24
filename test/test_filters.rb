# frozen_string_literal: true

require_relative "test-helper"

class TestFilters < Test::Unit::TestCase
  def test_filter_name_metadata
    assert_equal "affiliation", Serrano::Filters.names.min
  end

  def test_filter_detail_metadata
    expected_keys = %w[possible_values description].sort
    actual_keys = Serrano::Filters.filters["affiliation"].keys.sort
    assert_equal expected_keys, actual_keys
  end

  def test_method_alias
    assert_equal Serrano::Filters.names, Serrano.filters.names
    assert_equal Serrano::Filters.filters, Serrano.filters.filters
  end
end
