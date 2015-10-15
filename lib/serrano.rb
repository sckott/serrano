require "serrano/version"
require "serrano/request"
require "serrano/filterhandler"

# @!macro serrano_params
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
#   @param works [Boolean] If true, works returned as well. Default: false

##
# Serrano - The top level module for using methods
# to access Serrano APIs
#
# The following methods are available:
# * works - Use the /works endpoint
# * members - Use the /members endpoint
# * prefixes - Use the /prefixes endpoint
# * fundref - Use the /fundref endpoint
# * journals - Use the /journals endpoint
# * types - Use the /types endpoint
# * licenses - Use the /licenses endpoint
#
# All routes return an array of Faraday responses, which allows maximum flexibility.
# For example, if you want to inspect headers returned from the HTTP request,
# and parse the raw result in any way you wish.
#
# @see https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md for
# detailed description of the Crossref API
module Serrano
  ##
  # Search the works route
  #
  # @!macro serrano_params
  # @return [Array] An array of Faraday responses
  #
  # @example
  #     require 'serrano'
  #     # Search by DOI, one or more
  #     Serrano.works(ids: '10.5555/515151')
  #     Serrano.works(ids: '10.1371/journal.pone.0033693')
  #     Serrano.works(ids: ['10.1007/12080.1874-1746','10.1007/10452.1573-5125', '10.1111/(issn)1442-9993'])
  #     # query
  #     Serrano.works(query: "ecology")
  #     Serrano.works(query: "renear+-ontologies")
  #     # Sort
  #     Serrano.works(query: "ecology", sort: 'relevance', order: "asc")
  #     # Filters
  #     Serrano.works(filter: {has_full_text: true})
  #     Serrano.works(filter: {has_funder: true, has_full_text: true})
  #     Serrano.works(filter: {award_number: 'CBET-0756451', award_funder: '10.13039/100000001'})
  def self.works(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil, works: false)

    Request.new('works', ids, query, filter, offset,
      limit, sample, sort, order, facet, works).perform
  end

  ##
  # Search the members route
  #
  # @!macro serrano_params
  # @return [Array] An array of Faraday responses
  #
  # @example
  #     require 'serrano'
  #     # Search by DOI, one or more
  #     Serrano.members(ids: 98)
  #     Serrano.members(ids: 340)
  #     Serrano.members(ids: [98, 340, 45])
  #     # query
  #     Serrano.members(query: "ecology")
  #     Serrano.members(query: "hindawi")
  #     # Sort
  #     Serrano.members(query: "ecology", sort: 'relevance', order: "asc")
  #     # Works
  #     Serrano.members(ids: 98, works: true)
  def self.members(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil, works: false)

    Request.new('members', ids, query, filter, offset,
      limit, sample, sort, order, facet, works).perform
  end

  ##
  # Search the prefixes route
  #
  # @!macro serrano_params
  # @return [Array] An array of Faraday responses
  #
  # @example
  #     require 'serrano'
  #     # Search by DOI, one or more
  #     Serrano.prefixes(ids: "10.1016")
  #     Serrano.prefixes(ids: ['10.1016','10.1371','10.1023','10.4176','10.1093'])
  #     # works
  #     Serrano.prefixes(ids: "10.1016", works: true)
  #     # Limit number of results
  #     Serrano.prefixes(ids: "10.1016", works: true, limit: 3)
  #     # Sort and order
  #     Serrano.prefixes(ids: "10.1016", works: true, sort: 'relevance', order: "asc")
  def self.prefixes(ids:, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil, works: false)

    Request.new('prefixes', ids, nil, filter, offset,
      limit, sample, sort, order, facet, works).perform
  end

  ##
  # Search the fundref route
  #
  # @!macro serrano_params
  # @return [Array] An array of Faraday responses
  # @author Scott Chamberlain
  # @
  # @example
  #     require 'serrano'
  #     # Search by DOI, one or more
  #     Serrano.fundref(ids: '10.13039/100000001')
  #     Serrano.fundref(ids: ['10.13039/100000001','10.13039/100000015'])
  #     # query
  #     Serrano.fundref(query: "NSF")
  #     # works
  #     Serrano.fundref(ids: '10.13039/100000001', works: true)
  #     # Limit number of results
  #     Serrano.fundref(ids: '10.13039/100000001', works: true, limit: 3)
  #     # Sort and order
  #     Serrano.fundref(ids: "10.13039/100000001", works: true, sort: 'relevance', order: "asc")
  def self.fundref(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil, works: false)

    Request.new('funders', ids, query, filter, offset,
      limit, sample, sort, order, facet, works).perform
  end

  ##
  # Search the journals route
  #
  # @!macro serrano_params
  # @return [Array] An array of Faraday responses
  #
  # @example
  #     require 'serrano'
  #     Serrano.journals(ids: "2167-8359")
  #     Serrano.journals()
  #     Serrano.journals(ids: "2167-8359", works: TRUE)
  #     Serrano.journals(ids: ['1803-2427', '2326-4225'])
  #     Serrano.journals(query: "ecology")
  #     Serrano.journals(query: "peerj")
  #     Serrano.journals(ids: "2167-8359", query: 'ecology', works: TRUE, sort: 'score', order: "asc")
  #     Serrano.journals(ids: "2167-8359", query: 'ecology', works: TRUE, sort: 'score', order: "desc")
  #     Serrano.journals(ids: "2167-8359", works: TRUE, filter: {from_pub_date: '2014-03-03'})
  #     Serrano.journals(ids: '1803-2427', works: TRUE)
  #     Serrano.journals(ids: '1803-2427', works: TRUE, sample: 1)
  #     Serrano.journals(limit: 2)
  def self.journals(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil, works: false)

    Request.new('journals', ids, query, filter, offset,
      limit, sample, sort, order, facet, works).perform
  end

  ##
  # Search the types route
  #
  # @!macro serrano_params
  # @return [Array] An array of Faraday responses
  #
  # @example
  #     require 'serrano'
  #     Serrano.types(ids: "2167-8359")
  #     Serrano.types()
  def self.types(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil, works: false)

    Request.new('types', ids, query, filter, offset,
      limit, sample, sort, order, facet, works).perform
  end

  ##
  # Search the licenses route
  #
  # @!macro serrano_params
  # @return [Array] An array of Faraday responses
  #
  # @example
  #     require 'serrano'
  #     Serrano.licenses(ids: "2167-8359")
  #     Serrano.licenses()
  def self.licenses(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil, works: false)

    Request.new('licenses', ids, query, filter, offset,
      limit, sample, sort, order, facet, works).perform
  end
end
