# frozen_string_literal: true

require "erb"
require "faraday"
require "multi_json"
require "serrano/error"
require "serrano/utils"
require "serrano/helpers/configuration"

##
# Serrano::Request
#
# Class to perform HTTP requests to the Crossref API
module Serrano
  class Request # :nodoc:
    attr_accessor :endpt
    attr_accessor :id
    attr_accessor :query
    attr_accessor :filter
    attr_accessor :offset
    attr_accessor :limit
    attr_accessor :sample
    attr_accessor :sort
    attr_accessor :order
    attr_accessor :facet
    attr_accessor :select
    attr_accessor :works
    attr_accessor :agency
    attr_accessor :options
    attr_accessor :verbose

    def initialize(endpt, id, query, filter, offset,
      limit, sample, sort, order, facet, select,
      works, agency, options, verbose)

      self.endpt = endpt
      self.id = id
      self.query = query
      self.filter = filter
      self.offset = offset
      self.limit = limit
      self.sample = sample
      self.sort = sort
      self.order = order
      self.facet = facet
      self.select = select
      self.works = works
      self.agency = agency
      self.options = options
      self.verbose = verbose
    end

    def perform
      filt = filter_handler(filter)

      self.select = select&.instance_of?(Array) ? select.join(",") : select

      args = {query: query, filter: filt, offset: offset, rows: limit,
              sample: sample, sort: sort, order: order, facet: facet,
              select: select}
      opts = args.delete_if { |_k, v| v.nil? }

      conn = if verbose
        Faraday.new(url: Serrano.base_url, request: options || {}) do |f|
          f.response :logger
          f.use Faraday::SerranoErrors::Middleware
        end
      else
        Faraday.new(url: Serrano.base_url, request: options || {}) do |f|
          f.use Faraday::SerranoErrors::Middleware
        end
      end

      conn.headers[:user_agent] = make_ua
      conn.headers["X-USER-AGENT"] = make_ua

      if id.nil?
        res = conn.get endpt, opts
        MultiJson.load(res.body)
      else
        self.id = Array(id)
        # url encoding
        self.id = id.map { |x| ERB::Util.url_encode(x) }
        coll = []
        id.each do |x|
          endpt = if works
            self.endpt + "/" + x.to_s + "/works"
          elsif agency
            self.endpt + "/" + x.to_s + "/agency"
          else
            self.endpt + "/" + x.to_s
          end

          res = conn.get endpt, opts
          coll << MultiJson.load(res.body)
        end
        coll
      end
    end
  end
end
