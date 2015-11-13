require "serrano/version"
require "serrano/request"
require "serrano/filterhandler"
require "serrano/cnrequest"
require "serrano/miner"
require "serrano/filters"
require "serrano/cross_cite"

require 'rexml/document'
require 'rexml/xpath'

# @!macro serrano_params
#   @param offset [Fixnum] Number of record to start at, from 1 to infinity.
#   @param limit [Fixnum] Number of results to return. Not relavant when searching with specific dois. Default: 20. Max: 1000
#   @param sample [Fixnum] Number of random results to return. when you use the sample parameter,
#   the limit and offset parameters are ignored.
#   @param sort [String] Field to sort on, one of score, relevance,
#   updated (date of most recent change to metadata. Currently the same as deposited),
#   deposited (time of most recent deposit), indexed (time of most recent index), or
#   published (publication date). Note: If the API call includes a query, then the sort
#   order will be by the relevance score. If no query is included, then the sort order
#   will be by DOI update date.
#   @param order [String] Sort order, one of 'asc' or 'desc'
#   @param facet [Boolean] Include facet results. Default: false
#   @param verbose [Boolean] Print request headers to stdout. Default: false

# @!macro serrano_options
#   @param options [Hash] Hash of options for configuring the request, passed on to Faraday.new
#     :timeout      - [Fixnum] open/read timeout Integer in seconds
#     :open_timeout - [Fixnum] read timeout Integer in seconds
#     :proxy        - [Hash] hash of proxy options
#       :uri - [String] Proxy Server URI
#       :user - [String] Proxy server username
#       :password - [String] Proxy server password
#     :params_encoder - [Hash] not sure what this is
#     :bind           - [Hash] A hash with host and port values
#     :boundary       - [String] of the boundary value
#     :oauth          - [Hash] A hash with OAuth details

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
# * `Serrano.text` - Text and data mining
# * `Serrano.citation_count` - Citation count
# * `Serrano.crosscite` - CrossCite
# * `Serrano.csl_styles` - get CSL styles
#
# All routes return an array of hashes
# For example, if you want to inspect headers returned from the HTTP request,
# and parse the raw result in any way you wish.
#
# @see https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md for
# detailed description of the Crossref API
module Serrano
  extend Configuration

  define_setting :access_token
  define_setting :access_secret
  define_setting :elsevier_key
  define_setting :base_url, "http://api.crossref.org/"

  ##
  # Search the works route
  #
  # @!macro serrano_params
  # @!macro serrano_options
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
  #      # query
  #      Serrano.works(query: "ecology")
  #      Serrano.works(query: "renear+-ontologies")
  #      # Sort
  #      Serrano.works(query: "ecology", sort: 'relevance', order: "asc")
  #      # Filters
  #      Serrano.works(filter: {has_full_text: true})
  #      Serrano.works(filter: {has_funder: true, has_full_text: true})
  #      Serrano.works(filter: {award_number: 'CBET-0756451', award_funder: '10.13039/100000001'})
  #
  #      # Curl options
  #      ## set a request timeout and an open timeout
  #      Serrano.works(ids: '10.1371/journal.pone.0033693', options: {timeout: 3, open_timeout: 2})
  #      ## log request details - uses Faraday middleware
  #      Serrano.works(ids: '10.1371/journal.pone.0033693', verbose: true)
  def self.works(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    options: nil, verbose: false)

    Request.new('works', ids, query, filter, offset,
      limit, sample, sort, order, facet, nil, nil, options, verbose).perform
  end

  ##
  # Search the members route
  #
  # @!macro serrano_params
  # @!macro serrano_options
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
  def self.members(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    works: false, options: nil, verbose: false)

    Request.new('members', ids, query, filter, offset,
      limit, sample, sort, order, facet, works, nil, options, verbose).perform
  end

  ##
  # Search the prefixes route
  #
  # @!macro serrano_params
  # @!macro serrano_options
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
  def self.prefixes(ids:, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    works: false, options: nil, verbose: false)

    Request.new('prefixes', ids, nil, filter, offset,
      limit, sample, sort, order, facet, works, nil, options, verbose).perform
  end

  ##
  # Search the funders route
  #
  # @!macro serrano_params
  # @!macro serrano_options
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @param query [String] A query string
  # @param filter [Hash] Filter options. See ...
  # @param works [Boolean] If true, works returned as well. Default: false
  # @return [Array] An array of hashes
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
  def self.funders(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    works: false, options: nil, verbose: false)

    Request.new('funders', ids, query, filter, offset,
      limit, sample, sort, order, facet, works, nil, options, verbose).perform
  end

  ##
  # Search the journals route
  #
  # @!macro serrano_params
  # @!macro serrano_options
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
  def self.journals(ids: nil, query: nil, filter: nil, offset: nil,
    limit: nil, sample: nil, sort: nil, order: nil, facet: nil,
    works: false, options: nil, verbose: false)

    Request.new('journals', ids, query, filter, offset,
      limit, sample, sort, order, facet, works, nil, options, verbose).perform
  end

  ##
  # Search the types route
  #
  # @!macro serrano_options
  # @param ids [Array] DOIs (digital object identifier) or other identifiers
  # @param works [Boolean] If true, works returned as well. Default: false
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'serrano'
  #      Serrano.types()
  #      Serrano.types(ids: "journal")
  #      Serrano.types(ids: ["journal", "dissertation"])
  #      Serrano.types(ids: "journal", works: true)
  def self.types(ids: nil, offset: nil,
    limit: nil, works: false, options: nil, verbose: false)

    Request.new('types', ids, nil, nil, offset,
      limit, nil, nil, nil, nil, works, nil, options, verbose).perform
  end

  ##
  # Search the licenses route
  #
  # @!macro serrano_params
  # @!macro serrano_options
  # @param query [String] A query string
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

    Request.new('licenses', nil, query, nil, offset,
      limit, sample, sort, order, facet, nil, nil, options, verbose).perform
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

    Request.new('works', ids, nil, nil, nil,
      nil, nil, nil, nil, nil, false, true, options, verbose).perform
  end

  ##
  # Get a random set of DOI's
  #
  # @!macro serrano_options
  # @param sample [Fixnum] Number of random DOIs to return
  # @param verbose [Boolean] Print request headers to stdout. Default: false
  # @return [Array] A list of strings, each a DOI
  # @note This method uses {Serrano.works} internally, but doesn't allow you to pass on
  # arguments to that method.
  #
  # @example
  #      require 'serrano'
  #      Serrano.random_dois(sample: 1)
  #      Serrano.random_dois(sample: 10)
  #      Serrano.random_dois(sample: 100)
  def self.random_dois(sample:, options: nil, verbose: false)

    tmp = Request.new('works', nil, nil, nil, nil,
      nil, sample, nil, nil, nil, false, nil, options, verbose).perform
    tmp['message']['items'].collect { |x| x['DOI'] }
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
  #     # return an R bibentry type
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
  #     dois = cr_r(2)
  #     Serrano.content_negotiation(dois, format: "text", style: "apa")
  #
  #     # Using DataCite DOIs
  #     ## some formats don't work
  #     # Serrano.content_negotiation(ids: "10.5284/1011335", format: "text")
  #     # Serrano.content_negotiation(ids: "10.5284/1011335", format: "crossref-xml")
  #     # Serrano.content_negotiation(ids: "10.5284/1011335", format: "crossref-tdm")
  #
  #     ## But most do work
  #     Serrano.content_negotiation(ids: "10.5284/1011335", format: "datacite-xml")
  #     Serrano.content_negotiation(ids: "10.5284/1011335", format: "rdf-xml")
  #     Serrano.content_negotiation(ids: "10.5284/1011335", format: "turtle")
  #     Serrano.content_negotiation(ids: "10.5284/1011335", format: "citeproc-json")
  #     Serrano.content_negotiation(ids: "10.5284/1011335", format: "ris")
  #     Serrano.content_negotiation(ids: "10.5284/1011335", format: "bibtex")
  #     Serrano.content_negotiation(ids: "10.5284/1011335", format: "bibentry")
  #     Serrano.content_negotiation(ids: "10.5284/1011335", format: "bibtex")
  #
  #     # many DOIs
  #     dois = ['10.5167/UZH-30455','10.5167/UZH-49216','10.5167/UZH-503', '10.5167/UZH-38402','10.5167/UZH-41217']
  #     x = Serrano.content_negotiation(ids: dois)
  #     puts x
  def self.content_negotiation(ids:, format: "bibtex", style: 'apa', locale: "en-US")
    CNRequest.new(ids, format, style, locale).perform
  end

  ##
  # Get full text
  #
  # Should work for open access papers, but for closed, requires authentication and
  # likely pre-authorized IP address.
  #
  # @param url [String] A url for full text
  # @param type [Hash] Ignored for now. One of xml, plain, or pdf. Right now, type auto-detected from the URL
  # @return [Mined] An object of class Mined, with methods for extracting
  # the url requested, the file path, and parsing the plain text, XML, or extracting
  # text from the pdf.
  #
  # @example
  #   require 'serrano'
  #   # Set authorization
  #   Serrano.configuration do |config|
  #     config.elsevier_key = "<your key>"
  #   end
  #   # Get some elsevier works
  #   res = Serrano.members(ids: 78, works: true);
  #   # get full text links, here doing xml
  #   links = res[0]['message']['items'].collect { |x| x['link'].keep_if { |z| z['content-type'] == 'text/xml' } };
  #   links = links.collect { |z| z[0].select { |k,v| k[/URL/] }.values[0] };
  #   # Get full text for an article
  #   res = Serrano.text(url: links[0]);
  #   res.url
  #   res.path
  #   res.type
  #   xml = res.parse()
  #   puts xml
  #   xml.xpath('//xocs:cover-date-text', xml.root.namespaces).text
  #
  #   ## plain text
  #   # get full text links, here doing xml
  #   links = res[0]['message']['items'].collect { |x| x['link'].keep_if { |z| z['content-type'] == 'text/plain' } };
  #   links = links.collect { |z| z[0].select { |k,v| k[/URL/] }.values[0] };
  #   # Get full text for an article
  #   res = Serrano.text(url: links[0]);
  #   res.url
  #   res.parse
  #
  #   # With open access content - using Pensoft
  #   res = Serrano.members(ids: 2258, works: true, filter: {has_full_text: true});
  #   links = res[0]['message']['items'].collect { |x| x['link'].keep_if { |z| z['content-type'] == 'application/xml' } };
  #   links = links.collect { |z| z[0].select { |k,v| k[/URL/] }.values[0] };
  #   # Get full text for an article
  #   res = Serrano.text(url: links[0]);
  #   res.url
  #   res.parse
  def self.text(url:, type: 'xml')
    Miner.new(url, type).perform
  end

  # Get a citation count with a DOI
  #
  # @!macro serrano_options
  # @param doi [String] DOI, digital object identifier
  # @param url [String] the API url for the function (should be left to default)
  # @param key [String] your API key
  #
  # @see http://labs.crossref.org/openurl/ for more info on this Crossref API service.
  #
  # @example
  #   require 'serrano'
  #   Serrano.citation_count(doi: "10.1371/journal.pone.0042793")
  #   Serrano.citation_count(doi: "10.1016/j.fbr.2012.01.001")
  #   # DOI not found
  #   Serrano.citation_count(doi: "10.1016/j.fbr.2012")
  def self.citation_count(doi:, url: "http://www.crossref.org/openurl/",
    key: "cboettig@ropensci.org", options: nil)

    args = { id: "doi:" + doi, pid: key, noredirect: true }
    opts = args.delete_if { |k, v| v.nil? }
    conn = Faraday.new(:url => url, :request => options)
    res = conn.get '', opts
    x = res.body
    oc = REXML::Document.new("<doc>#{x}</doc>")
    value = REXML::XPath.first(oc, '//query').attributes['fl_count'].to_i
    return value
  end

  # Crosscite - citation formatter
  #
  # @!macro serrano_options
  # @param doi [String,Array] Search by a single DOI or many DOIs.
  # @param style [String] a CSL style (for text format only). See {Serrano.csl_styles}
  # for options. Default: apa. If there's a style that CrossRef doesn't support you'll get
  # @param locale [String] Language locale
  #
  # @see http://www.crosscite.org/cn/ for more info on the
  #    Crossref Content Negotiation API service
  #
  # @example
  #   Serrano.crosscite(doi: "10.5284/1011335")
  #   Serrano.crosscite(doi: ['10.5169/SEALS-52668','10.2314/GBV:493109919','10.2314/GBV:493105263','10.2314/GBV:487077911','10.2314/GBV:607866403'])
  def self.crosscite(doi:, style: 'apa', locale: "en-US", options: nil)
    doi = Array(doi)
    if doi.length > 1
      coll = []
      doi.each do |x|
        begin
          coll << ccite(x, style, locale, options)
        rescue Exception => e
          raise e
        end
      end
      return coll
    else
      return ccite(doi[0], style, locale, options)
    end
  end

  # Get csl styles
  #
  # @see https://github.com/citation-style-language/styles
  #
  # @example
  #   Serrano.csl_styles
  def self.csl_styles
    get_styles()
  end

end
