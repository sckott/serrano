require 'httparty'
require 'json'
require "crossrefrb/version"
require "crossrefrb/request"
require "crossrefrb/filterhandler"

# @!macro crossref_params
#   @param ids [Array] DOIs (digital object identifier) or other identifiers
#   @param query [String] A query string
#   @param filter [Hash] Filter options. See ...
#   @param offset [Fixnum] Number of record to start at, from 1 to infinity.
#   @param limit [Fixnum] Number of results to return. Not relavant when searching with specific dois. Default: 20. Max: 1000
#   @param sample [Fixnum] Number of random results to return. when you use the sample parameter,
#   the limit and offset parameters are ignored.
#   @param sort [String] Field to sort on, one of score, relevance, updated, deposited, indexed,
#   or published.
#   @param order [String] Sort order, one of 'asc' or 'desc'
#   @param facet [Boolean] Include facet results. Default: false

##
# Crossref - The top level module for using methods
# to access Crossref APIs
#
# The following methods are available:
# * works - Use the /works endpoint
# * members - use the /members endpoint
module Crossref
  ##
  # Search the works API
  #
  # @!macro crossref_params
  # @return [Array] the output
  #
  # @example
  #     require 'crossrefrb'
  #     # Search by DOI, one or more
  #     Crossref.works(ids: '10.5555/515151')
  #     Crossref.works(ids: '10.1371/journal.pone.0033693')
  #     Crossref.works(ids: ['10.1007/12080.1874-1746','10.1007/10452.1573-5125', '10.1111/(issn)1442-9993'])
  #     # query
  #     Crossref.works(query: "ecology")
  #     Crossref.works(query: "renear+-ontologies")
  #     # Sort
  #     Crossref.works(query: "ecology", sort: 'relevance', order: "asc")
  def self.works(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil)

    Request.new('works', ids, query, filter, offset,
      limit, sample, sort, order, facet).perform
  end

  ##
  # Search the members API
  #
  # @!macro crossref_params
  # @return [Array] the output
  #
  # @example
  #     require 'crossrefrb'
  #     # Search by DOI, one or more
  #     Crossref.members(ids: 98)
  #     Crossref.members(ids: 340)
  #     Crossref.members(ids: [98, 340, 45])
  #     # query
  #     Crossref.members(query: "ecology")
  #     Crossref.members(query: "hindawi")
  #     # Sort
  #     Crossref.members(query: "ecology", sort: 'relevance', order: "asc")
  def self.members(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil)

    Request.new('members', ids, query, filter, offset,
      limit, sample, sort, order, facet).perform
  end
end
