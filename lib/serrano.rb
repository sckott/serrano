# frozen_string_literal: true

require "erb"
require "serrano/version"
require "serrano/request"
require "serrano/request_cursor"
require "serrano/filterhandler"
require "serrano/cnrequest"
require "serrano/filters"
require "serrano/styles"

require "rexml/document"
require "rexml/xpath"

# @!macro serrano_params
#   @param offset [Fixnum] Number of record to start at, any non-negative integer up to 10,000
#   @param limit [Fixnum] Number of results to return. Not relavant when searching with specific dois.
#       Default: 20. Max: 1000
#   @param sample [Fixnum] Number of random results to return. when you use the sample parameter,
#       the limit and offset parameters are ignored. This parameter only used when works requested.
#       Max: 100.
#   @param sort [String] Field to sort on, one of score, relevance,
#       updated (date of most recent change to metadata - currently the same as deposited),
#       deposited (time of most recent deposit), indexed (time of most recent index),
#       published (publication date), published-print (print publication date),
#       published-online (online publication date), issued (issued date (earliest known publication date)),
#       is-referenced-by-count (number of times this DOI is referenced by other Crossref DOIs), or
#       references-count (number of references included in the references section of the document
#       identified by this DOI). Note: If the API call includes a query, then the sort
#       order will be by the relevance score. If no query is included, then the sort order
#       will be by DOI update date.
#   @param order [String] Sort order, one of 'asc' or 'desc'
#   @param facet [Boolean/String] Include facet results OR a query (e.g., `license:*`) to facet by
#       license. Default: false
#   @param select [String/Array(String)] Crossref metadata records can be
#       quite large. Sometimes you just want a few elements from the schema. You can "select"
#       a subset of elements to return. This can make your API calls much more efficient. Not
#       clear yet which fields are allowed here.
#   @param verbose [Boolean] Print request headers to stdout. Default: false

# @!macro cursor_params
#   @param cursor [String] Cursor character string to do deep paging. Default is `nil`.
#       Pass in '*' to start deep paging. Any combination of query, filters and facets may be
#       used with deep paging cursors. While limit may be specified along with cursor, offset
#       and sample cannot be used. See https://api.crossref.org/
#   @param cursor_max [Fixnum] Max records to retrieve. Only used when cursor
#       param used. Because deep paging can result in continuous requests until all
#       are retrieved, use this parameter to set a maximum number of records. Of course,
#       if there are less records found than this value, you will get only those found.

# @!macro serrano_options
#   @param options [Hash] Hash of options for configuring the request, passed on to Faraday.new
#     - timeout [Fixnum] open/read timeout Integer in seconds
#     - open_timeout [Fixnum] read timeout Integer in seconds
#     - proxy [Hash] hash of proxy options
#       - uri [String] Proxy Server URI
#       - user [String] Proxy server username
#       - password [String] Proxy server password
#     - params_encoder [Hash] not sure what this is
#     - bind [Hash] A hash with host and port values
#     - boundary [String] of the boundary value
#     - oauth [Hash] A hash with OAuth details

# @!macro field_queries
#   @param [Hash<Object>] args Field queries, as named parameters. See https://api.crossref.org/
#       Field query parameters mut be named, and must start with `query_`. Any dashes or
#       periods should be replaced with underscores. The options include:
#       - query_container_title: Query container-title aka. publication name
#       - query_author: Query author given and family names
#       - query_editor: Query editor given and family names
#       - query_chair: Query chair given and family names
#       - query_translator: Query translator given and family names
#       - query_contributor: Query author, editor, chair and translator given and family names
#       - query_bibliographic: Query bibliographic information, useful for citation look up. Includes titles, authors, ISSNs and publication years
#       - query_affiliation: Query contributor affiliations

##
# Serrano - The top level module for using methods
# to access Serrano APIs
#
# The following methods, matching the main Crossref API routes, are available:
# * `Serrano.works` - Use the /works endpoint
# * `Serrano.members` - Use the /members endpoint
# * `Serrano.prefixes` - Use the /prefixes endpoint
# * `Serrano.funders` - Use the /funders endpoint
# * `Serrano.journals` - Use the /journals endpoint
# * `Serrano.types` - Use the /types endpoint
# * `Serrano.licenses` - Use the /licenses endpoint
#
# Additional methods
# * `Serrano.agency` - test the registration agency for a DOI
# * `Serrano.content_negotiation` - Conent negotiation
# * `Serrano.citation_count` - Citation count
# * `Serrano.csl_styles` - get CSL styles
#
# All routes return an array of hashes
# For example, if you want to inspect headers returned from the HTTP request,
# and parse the raw result in any way you wish.
#
# @see https://api.crossref.org for detailed description of the Crossref API
#
# What am I actually searching when using the Crossref search API?
#
# You are using the Crossref search API described at https://api.crossref.org
# When you search with query terms, on Crossref servers they are not
# searching full text, or even abstracts of articles, but only what is
# available in the data that is returned to you. That is, they search
# article titles, authors, etc. For some discussion on this, see
# https://gitlab.com/crossref/issues/-/issues/101
#
#
# The Polite Pool
# As of September 18th 2017 any API queries that use HTTPS and have
# appropriate contact information will be directed to a special pool
# of API machines that are reserved for polite users. If you connect
# to the Crossreef API using HTTPS and provide contact
# information, then they will send you to a separate pool of machines,
# with better control the performance of these machines because they can
# block abusive users.
#
# We have been using `https` in `serrano` for a while now, so that's good
# to go. To get into the Polite Pool, also set your `mailto` email address
# with `Serrano.configuration` (example below), or set as an environment
# variable with the name `CROSSREF_EMAIL` and your mailto will be set
# for each request automatically.
#
# require 'serrano'
# Serrano.configuration do |config|
#   config.mailto = "foo@bar.com"
# end
#
#
# Rate limiting
# Crossref introduced rate limiting recently. The rate limits apparently vary,
# so we can't give a predictable rate limit. As of this writing, the rate
# limit is 50 requests per second. Look for the headers `X-Rate-Limit-Limit`
# and `X-Rate-Limit-Interval` in requests to see what the current rate
# limits are.
#
#
# URL Encoding
# We do URL encoding of DOIs for you for all methods except `Serrano.citation_count`
# which doesn't work if you encode DOIs beforehand. We use `ERB::Util.url_encode`
# to encode.

module Serrano
  extend Configuration

  define_setting :access_token
  define_setting :access_secret
  define_setting :mailto, ENV["CROSSREF_EMAIL"]
  define_setting :base_url, "https://api.crossref.org/"

  ##
  # Search the works route
  #
  # @!macro serrano_params
  # @!macro serrano_options
  # @!macro cursor_params
  # @!macro field_queries
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @param query [String] A query string
  # @param filter [Hash] Filter options. See ...
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'serrano'
  #      # Search by DOI, one or more
  #      Serrano.works(ids: '10.5555/515151')
  #      Serrano.works(ids: '10.1371/journal.pone.0033693')
  #      Serrano.works(ids: ['10.1007/12080.1874-1746','10.1007/10452.1573-5125', '10.1111/(issn)1442-9993'])
  #      Serrano.works(ids: ["10.1016/0304-4009(81)90025-5", "10.1016/0304-4009(83)90036-0"])
  #
  #      # query
  #      Serrano.works(query: "ecology")
  #      Serrano.works(query: "renear+-ontologies")
  #
  #      # Sort
  #      Serrano.works(query: "ecology", sort: 'relevance', order: "asc")
  #
  #      # Filters
  #      Serrano.works(filter: {has_full_text: true})
  #      res = Serrano.works(filter: {has_full_text: true})
  #      Serrano.works(filter: {has_funder: true, has_full_text: true})
  #      Serrano.works(filter: {award_number: 'CBET-0756451', award_funder: '10.13039/100000001'})
  #      Serrano.works(filter: {has_abstract: true})
  #      Serrano.works(filter: {has_clinical_trial_number: true})
  #
  #      # Curl options
  #      ## set a request timeout and an open timeout
  #      Serrano.works(ids: '10.1371/journal.pone.0033693', options: {timeout: 3, open_timeout: 2})
  #      ## log request details - uses Faraday middleware
  #      Serrano.works(ids: '10.1371/journal.pone.0033693', verbose: true)
  #
  #      # facets
  #      Serrano.works(facet: 'license:*', limit: 0, filter: {has_full_text: true})
  #
  #      # sample
  #      Serrano.works(sample: 2)
  #
  #      # select - pass an array or a comma separated string
  #      Serrano.works(query: "ecology", select: "DOI,title", limit: 30)
  #      Serrano.works(query: "ecology", select: ["DOI","title"], limit: 30)
  #
  #      # cursor for deep paging
  #      Serrano.works(query: "widget", cursor: "*", limit: 100, cursor_max: 1000)
  #      # another query, more results this time
  #      res = Serrano.works(query: "science", cursor: "*", limit: 250, cursor_max: 1000);
  #      res.collect { |x| x['message']['items'].length }.reduce(0, :+)
  #      # another query
  #      res = Serrano.works(query: "ecology", cursor: "*", limit: 1000, cursor_max: 10000);
  #      res.collect { |x| x['message']['items'].length }.reduce(0, :+)
  #      items = res.collect {|x| x['message']['items']}.flatten
  #      items.collect { |x| x['DOI'] }[0,20]
  #
  #      # field queries
  #      ## query.author
  #      res = Serrano.works(query: "ecology", query_author: 'Boettiger')
  #      res['message']['items'].collect { |x| x['author'][0]['family'] }
  #
  #      ## query.container-title
  #      res = Serrano.works(query: "ecology", query_container_title: 'Ecology')
  #      res['message']['items'].collect { |x| x['container-title'] }
  #
  #      # select certain fields
  #      Serrano.works(select: ['DOI', 'title'], limit: 3)
  def self.works(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    select: nil, options: nil, verbose: false, cursor: nil,
    cursor_max: 5000, **args)

    assert_valid_filters(filter) if filter
    RequestCursor.new("works", ids, query, filter, offset,
      limit, sample, sort, order, facet, select, nil, nil, options,
      verbose, cursor, cursor_max, args).perform
  end

  ##
  # Search the members route
  #
  # @!macro serrano_params
  # @!macro serrano_options
  # @!macro cursor_params
  # @!macro field_queries
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @param query [String] A query string
  # @param filter [Hash] Filter options. See ...
  # @param works [Boolean] If true, works returned as well. Default: false
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'serrano'
  #      # Search by DOI, one or more
  #      Serrano.members(ids: 98)
  #      Serrano.members(ids: 340)
  #      Serrano.members(ids: [98, 340, 45])
  #      # query
  #      Serrano.members(query: "ecology")
  #      Serrano.members(query: "hindawi")
  #      # Sort - weird, doesn't work
  #      Serrano.members(query: "ecology", order: "asc")
  #      # Works
  #      Serrano.members(ids: 98, works: true)
  #
  #      # cursor - deep paging
  #      res = Serrano.members(ids: 98, works: true, cursor: "*", cursor_max: 1000);
  #      res[0].collect { |x| x['message']['items'].length }.reduce(0, :+)
  #      items = res[0].collect { |x| x['message']['items'] }.flatten
  #      items.collect{ |z| z['DOI'] }[0,50]
  #
  #      # multiple ids with cursor
  #      res = Serrano.members(ids: [98, 340], works: true, cursor: "*", cursor_max: 300);
  #      res[0].collect { |x| x['message']['items'].length }.reduce(0, :+)
  #      items = res[0].collect { |x| x['message']['items'] }.flatten
  #      items.collect{ |z| z['DOI'] }[0,50]
  #
  #      # field queries
  #      ## query.title
  #      res = Serrano.members(ids: 221, works: true, query_container_title: 'Advances')
  #      res[0]['message']['items'].collect { |x| x['container-title'] }
  #
  #      # select certain fields
  #      Serrano.members(ids: 340, works: true, select: ['DOI', 'title'], limit: 3)
  def self.members(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    select: nil, works: false, options: nil, verbose: false,
    cursor: nil, cursor_max: 5000, **args)

    assert_valid_filters(filter) if filter
    RequestCursor.new("members", ids, query, filter, offset,
      limit, sample, sort, order, facet, select, works, nil,
      options, verbose, cursor, cursor_max, args).perform
  end

  ##
  # Search the prefixes route
  #
  # @!macro serrano_params
  # @!macro serrano_options
  # @!macro cursor_params
  # @!macro field_queries
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @param filter [Hash] Filter options. See ...
  # @param works [Boolean] If true, works returned as well. Default: false
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'serrano'
  #      # Search by DOI, one or more
  #      Serrano.prefixes(ids: "10.1016")
  #      Serrano.prefixes(ids: ['10.1016','10.1371','10.1023','10.4176','10.1093'])
  #      # works
  #      Serrano.prefixes(ids: "10.1016", works: true)
  #      # Limit number of results
  #      Serrano.prefixes(ids: "10.1016", works: true, limit: 3)
  #      # Sort and order
  #      Serrano.prefixes(ids: "10.1016", works: true, sort: 'relevance', order: "asc")
  #
  #      # cursor - deep paging
  #      res = Serrano.prefixes(ids: "10.1016", works: true, cursor: "*", cursor_max: 1000);
  #      res[0].collect { |x| x['message']['items'].length }.reduce(0, :+)
  #      items = res[0].collect { |x| x['message']['items'] }.flatten;
  #      items.collect{ |z| z['DOI'] }[0,50]
  #
  #      # field queries
  #      ## query.bibliographic
  #      res = Serrano.prefixes(ids: "10.1016", works: true, query_bibliographic: 'cell biology')
  #      res[0]['message']['items'].collect { |x| x['title'] }
  #
  #      # select certain fields
  #      Serrano.prefixes(ids: "10.1016", works: true, select: ['DOI', 'title'], limit: 3)
  def self.prefixes(ids:, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    select: nil, works: false, options: nil, verbose: false,
    cursor: nil, cursor_max: 5000, **args)

    assert_valid_filters(filter) if filter
    RequestCursor.new("prefixes", ids, nil, filter, offset,
      limit, sample, sort, order, facet, select, works, nil,
      options, verbose, cursor, cursor_max, args).perform
  end

  ##
  # Search the funders route
  #
  # @!macro serrano_params
  # @!macro serrano_options
  # @!macro cursor_params
  # @!macro field_queries
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @param query [String] A query string
  # @param filter [Hash] Filter options. See ...
  # @param works [Boolean] If true, works returned as well. Default: false
  # @return [Array] An array of hashes
  #
  # @note Funders without IDs don't show up on the /funders route
  #
  # @example
  #      require 'serrano'
  #      # Search by DOI, one or more
  #      Serrano.funders(ids: 100004410)
  #      Serrano.funders(ids: ['10.13039/100000001','10.13039/100000015'])
  #      # query
  #      Serrano.funders(query: "NSF")
  #      # works
  #      Serrano.funders(ids: '10.13039/100000001', works: true)
  #      # Limit number of results
  #      Serrano.funders(ids: '10.13039/100000001', works: true, limit: 3)
  #      # Sort and order
  #      Serrano.funders(ids: "10.13039/100000001", works: true, sort: 'relevance', order: "asc")
  #
  #      # cursor - deep paging
  #      res = Serrano.funders(ids: '10.13039/100000001', works: true, cursor: "*", cursor_max: 500);
  #      res[0].collect { |x| x['message']['items'].length }.reduce(0, :+)
  #      items = res[0].collect { |x| x['message']['items'] }.flatten;
  #      items.collect{ |z| z['DOI'] }[0,50]
  #
  #      # field queries
  #      ## query.title
  #      res = Serrano.funders(ids: "10.13039/100000001", works: true, query_author: 'Simon')
  #      res[0]['message']['items'].collect { |x| x['author'][0]['family'] }
  #
  #      # select certain fields
  #      Serrano.funders(ids: "10.13039/100000001", works: true, select: ['DOI', 'title'], limit: 3)
  def self.funders(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    select: nil, works: false, options: nil, verbose: false,
    cursor: nil, cursor_max: 5000, **args)

    assert_valid_filters(filter) if filter
    RequestCursor.new("funders", ids, query, filter, offset,
      limit, sample, sort, order, facet, select, works, nil, options,
      verbose, cursor, cursor_max, args).perform
  end

  ##
  # Search the journals route
  #
  # @!macro serrano_params
  # @!macro serrano_options
  # @!macro cursor_params
  # @!macro field_queries
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @param query [String] A query string
  # @param filter [Hash] Filter options. See ...
  # @param works [Boolean] If true, works returned as well. Default: false
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'serrano'
  #      Serrano.journals(ids: "2167-8359")
  #      Serrano.journals()
  #      Serrano.journals(ids: "2167-8359", works: true)
  #      Serrano.journals(ids: ['1803-2427', '2326-4225'])
  #      Serrano.journals(query: "ecology")
  #      Serrano.journals(query: "peerj")
  #      Serrano.journals(ids: "2167-8359", query: 'ecology', works: true, sort: 'score', order: "asc")
  #      Serrano.journals(ids: "2167-8359", query: 'ecology', works: true, sort: 'score', order: "desc")
  #      Serrano.journals(ids: "2167-8359", works: true, filter: {from_pub_date: '2014-03-03'})
  #      Serrano.journals(ids: '1803-2427', works: true)
  #      Serrano.journals(ids: '1803-2427', works: true)
  #      Serrano.journals(limit: 2)
  #      Serrano.journals(sample: 2)
  #
  #      # cursor - deep paging
  #      res = Serrano.journals(ids: "2167-8359", works: true, cursor: "*", cursor_max: 500);
  #      res[0].collect { |x| x['message']['items'].length }.reduce(0, :+)
  #      items = res[0].collect { |x| x['message']['items'] }.flatten;
  #      items.collect{ |z| z['DOI'] }[0,50]
  #
  #      # field queries
  #      ## query.title
  #      res = Serrano.journals(ids: "2167-8359", works: true, query_container_title: 'Advances')
  #      res[0]['message']['items'].collect { |x| x['container-title'] }
  #
  #      # select certain fields
  #      Serrano.journals(ids: "2167-8359", works: true, select: ['DOI', 'title'], limit: 3)
  def self.journals(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    select: nil, works: false, options: nil, verbose: false,
    cursor: nil, cursor_max: 5000, **args)

    assert_valid_filters(filter) if filter
    RequestCursor.new("journals", ids, query, filter, offset,
      limit, sample, sort, order, facet, select, works, nil, options,
      verbose, cursor, cursor_max, args).perform
  end

  ##
  # Search the types route
  #
  # @!macro serrano_options
  # @!macro cursor_params
  # @!macro field_queries
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @param works [Boolean] If true, works returned as well. Default: false
  # @param select [String/Array(String)] Crossref metadata records can be
  #     quite large. Sometimes you just want a few elements from the schema. You can "select"
  #     a subset of elements to return. This can make your API calls much more efficient. Not
  #     clear yet which fields are allowed here.
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'serrano'
  #      Serrano.types()
  #      Serrano.types(ids: "journal")
  #      Serrano.types(ids: ["journal", "dissertation"])
  #      Serrano.types(ids: "journal", works: true)
  #
  #      # cursor - deep paging
  #      res = Serrano.types(ids: "journal", works: true, cursor: "*", cursor_max: 500);
  #      res[0].collect { |x| x['message']['items'].length }.reduce(0, :+)
  #      items = res[0].collect { |x| x['message']['items'] }.flatten;
  #      items.collect{ |z| z['DOI'] }[0,50]
  #
  #      # field queries
  #      ## query.title
  #      res = Serrano.types(ids: "journal", works: true, query_container_title: 'Advances')
  #      res[0]['message']['items'].collect { |x| x['container-title'] }
  #
  #      # select certain fields
  #      Serrano.types(ids: "journal", works: true, select: ['DOI', 'title'], limit: 3)
  def self.types(ids: nil, offset: nil, limit: nil, select: nil, works: false,
    options: nil, verbose: false, cursor: nil, cursor_max: 5000, **args)

    RequestCursor.new("types", ids, nil, nil, offset,
      limit, nil, nil, nil, nil, select, works, nil, options,
      verbose, cursor, cursor_max, args).perform
  end

  ##
  # Search the licenses route
  #
  # @!macro serrano_options
  # @param query [String] A query string
  # @param offset [Fixnum] Number of record to start at, any non-negative integer up to 10,000
  # @param limit [Fixnum] Number of results to return. Not relavant when searching with specific dois.
  #       Default: 20. Max: 1000
  # @param sample [Fixnum] Number of random results to return. when you use the sample parameter,
  #       the limit and offset parameters are ignored. This parameter only used when works requested.
  #       Max: 100.
  # @param sort [String] Field to sort on, one of score, relevance,
  #       updated (date of most recent change to metadata - currently the same as deposited),
  #       deposited (time of most recent deposit), indexed (time of most recent index),
  #       published (publication date), published-print (print publication date),
  #       published-online (online publication date), issued (issued date (earliest known publication date)),
  #       is-referenced-by-count (number of times this DOI is referenced by other Crossref DOIs), or
  #       references-count (number of references included in the references section of the document
  #       identified by this DOI). Note: If the API call includes a query, then the sort
  #       order will be by the relevance score. If no query is included, then the sort order
  #       will be by DOI update date.
  # @param order [String] Sort order, one of 'asc' or 'desc'
  # @param facet [Boolean/String] Include facet results OR a query (e.g., `license:*`) to facet by
  #       license. Default: false
  # @param verbose [Boolean] Print request headers to stdout. Default: false
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'serrano'
  #      Serrano.licenses(query: "creative")
  #      Serrano.licenses()
  #      Serrano.licenses(limit: 3)
  def self.licenses(query: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil,
    facet: nil, options: nil, verbose: false)

    Request.new("licenses", nil, query, nil, offset,
      limit, sample, sort, order, facet, nil, nil, nil, options, verbose).perform
  end

  ##
  # Determine registration agency for DOIs
  #
  # @!macro serrano_options
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'serrano'
  #      Serrano.registration_agency(ids: '10.1371/journal.pone.0033693')
  #      Serrano.registration_agency(ids: ['10.1007/12080.1874-1746','10.1007/10452.1573-5125', '10.1111/(issn)1442-9993'])
  def self.registration_agency(ids:, options: nil, verbose: false)
    Request.new("works", ids, nil, nil, nil,
      nil, nil, nil, nil, nil, nil, false, true, options, verbose).perform
  end

  ##
  # Get a random set of DOI's
  #
  # @!macro serrano_options
  # @param sample [Fixnum] Number of random DOIs to return. Max: 100. Default: 10
  # @param verbose [Boolean] Print request headers to stdout. Default: false
  # @return [Array] A list of strings, each a DOI
  # @note This method uses {Serrano.works} internally, but doesn't allow you to pass on
  # arguments to that method.
  #
  # @example
  #      require 'serrano'
  #      # by default, gives 10
  #      Serrano.random_dois()
  #      Serrano.random_dois(sample: 1)
  #      Serrano.random_dois(sample: 10)
  #      Serrano.random_dois(sample: 100)
  def self.random_dois(sample: 10, options: nil, verbose: false)
    tmp = Request.new("works", nil, nil, nil, nil,
      nil, sample, nil, nil, nil, nil, false, nil, options, verbose).perform
    tmp["message"]["items"].collect { |x| x["DOI"] }
  end

  ##
  # Get citations in various formats from CrossRef
  #
  # @param ids [String] DOIs
  # @param format [String] Format
  # @param style [String] Style
  # @param locale [String] Locale
  # @return [Hash] A hash
  #
  # @example
  #     require 'serrano'
  #     # By default, you get bibtex, apa format, in en-US locale
  #     Serrano.content_negotiation(ids: '10.1126/science.169.3946.635')
  #
  #     # get citeproc-json
  #     Serrano.content_negotiation(ids: '10.1126/science.169.3946.635', format: "citeproc-json")
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "citeproc-json")
  #
  #     # some other formats
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "rdf-xml")
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "crossref-xml")
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "text")
  #
  #     # return a bibentry type
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "bibentry")
  #     Serrano.content_negotiation(ids: "10.6084/m9.figshare.97218", format: "bibentry")
  #
  #     # return an apa style citation
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "text", style: "apa")
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "text", style: "harvard3")
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "text", style: "elsevier-harvard")
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "text", style: "ecoscience")
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "text", style: "heredity")
  #     Serrano.content_negotiation(ids: "10.1126/science.169.3946.635", format: "text", style: "oikos")
  #
  #     # example with many DOIs
  #     dois = Serrano.random_dois(sample: 2)
  #     Serrano.content_negotiation(ids: dois, format: "text", style: "apa")
  #
  #     # Using DataCite DOIs
  #     doi = "10.1126/science.169.3946.635"
  #     Serrano.content_negotiation(ids: doi, format: "text")
  #     Serrano.content_negotiation(ids: doi, format: "crossref-xml")
  #     Serrano.content_negotiation(ids: doi, format: "crossref-tdm")
  #
  #     ## But most do work
  #     Serrano.content_negotiation(ids: doi, format: "datacite-xml")
  #     Serrano.content_negotiation(ids: doi, format: "rdf-xml")
  #     Serrano.content_negotiation(ids: doi, format: "turtle")
  #     Serrano.content_negotiation(ids: doi, format: "citeproc-json")
  #     Serrano.content_negotiation(ids: doi, format: "ris")
  #     Serrano.content_negotiation(ids: doi, format: "bibtex")
  #     Serrano.content_negotiation(ids: doi, format: "bibentry")
  #     Serrano.content_negotiation(ids: doi, format: "bibtex")
  #
  #     # many DOIs
  #     dois = ['10.5167/UZH-30455','10.5167/UZH-49216','10.5167/UZH-503',
  #      '10.5167/UZH-38402','10.5167/UZH-41217']
  #     x = Serrano.content_negotiation(ids: dois)
  #     puts x
  def self.content_negotiation(ids:, format: "bibtex", style: "apa", locale: "en-US")
    ids = Array(ids).map { |x| ERB::Util.url_encode(x) }
    CNRequest.new(ids, format, style, locale).perform
  end

  # Get a citation count with a DOI
  #
  # @!macro serrano_options
  # @param doi [String] DOI, digital object identifier
  # @param url [String] the API url for the function (should be left to default)
  # @param key [String] your API key
  #
  # @see https://www.crossref.org/documentation/retrieve-metadata/openurl/ for
  # more info on this Crossref API service.
  #
  # @example
  #   require 'serrano'
  #   Serrano.citation_count(doi: "10.1371/journal.pone.0042793")
  #   Serrano.citation_count(doi: "10.1016/j.fbr.2012.01.001")
  #   # DOI not found
  #   Serrano.citation_count(doi: "10.1016/j.fbr.2012")
  def self.citation_count(doi:, url: "https://www.crossref.org/openurl/",
    key: "cboettig@ropensci.org", options: nil)

    args = {id: "doi:" + doi, pid: key, noredirect: true}
    opts = args.delete_if { |_k, v| v.nil? }
    conn = Faraday.new(url: url, request: options)
    res = conn.get "", opts
    x = res.body
    oc = REXML::Document.new("<doc>#{x}</doc>")
    REXML::XPath.first(oc, "//query").attributes["fl_count"].to_i
  end

  # Get csl styles
  #
  # @see https://github.com/citation-style-language/styles
  #
  # @example
  #   Serrano.csl_styles
  def self.csl_styles
    fetch_styles
  end

  def self.assert_valid_filters(filters)
    unless filters.is_a? Hash
      raise ArgumentError, <<~ERR
        Filters must be provided as a hash, like:

            Serrano.works(query: "something", filters: { has_abstract: true })
      ERR
    end

    filters.each do |name, _|
      filter_strings = Filters.names.map(&:to_s)
      next if filter_strings.include?(name.to_s)

      raise ArgumentError, <<~ERR
        The filter "#{name}" is not a valid filter. Please run `Serrano.filters.filters` to see all valid filters.
      ERR
    end
  end
end
