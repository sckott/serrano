# frozen_string_literal: true

require "erb"
require "faraday"
require "multi_json"
require "serrano/error"
require "serrano/helpers/configuration"
require "serrano/filterhandler"
require "serrano/faraday"
require "serrano/utils"

##
# Serrano::RequestCursor
#
# Class to perform HTTP requests to the Crossref API
module Serrano
  class RequestCursor # :nodoc:
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
    attr_accessor :cursor
    attr_accessor :cursor_max
    attr_accessor :args

    def initialize(endpt, id, query, filter, offset,
      limit, sample, sort, order, facet, select,
      works, agency, options, verbose, cursor,
      cursor_max, args)

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
      self.cursor = cursor
      self.cursor_max = cursor_max
      self.args = args
    end

    def perform
      filt = filter_handler(filter)
      fieldqueries = field_query_handler(args)
      self.select = select&.instance_of?(Array) ? select.join(",") : select

      unless cursor_max.class.nil?
        raise "cursor_max must be of class int" unless cursor_max.is_a?(Integer)
      end

      arguments = {query: query, filter: filt, offset: offset,
                   rows: limit, sample: sample, sort: sort,
                   order: order, facet: facet, select: select,
                   cursor: cursor}.tostrings
      arguments = arguments.merge(fieldqueries)
      opts = arguments.delete_if { |_k, v| v.nil? }

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
        endpt2 = endpt
        js = _req(conn, endpt, opts)
        cu = js["message"]["next-cursor"]
        max_avail = js["message"]["total-results"]
        _redo_req(conn, js, opts, cu, max_avail, endpt2)

      else
        self.id = Array(id)
        # url encoding
        self.id = id.map { |x| ERB::Util.url_encode(x) }
        coll = []
        id.each do |x|
          endpt2 = if works
            endpt + "/" + x.to_s + "/works"
          else
            endpt2 = if agency
              endpt + "/" + x.to_s + "/agency"
            else
              endpt + "/" + x.to_s
            end
          end

          js = _req(conn, endpt2, opts)
          cu = js["message"]["next-cursor"]
          max_avail = js["message"]["total-results"]
          coll << _redo_req(conn, js, opts, cu, max_avail, endpt2)
        end
        coll
      end
    end

    def _redo_req(conn, js, opts, cu, max_avail, endpt2)
      if !cu.nil? && (cursor_max > js["message"]["items"].length)
        res = [js]
        total = js["message"]["items"].length
        while !cu.nil? && (cursor_max > total) && (total < max_avail)
          opts[:cursor] = cu
          out = _req(conn, endpt2, opts)
          cu = out["message"]["next-cursor"]
          res << out
          total = res.collect { |x| x["message"]["items"].length }.sum
        end
        res
      else
        js
      end
    end

    def _req(conn, path, opts)
      res = conn.get path, opts
      MultiJson.load(res.body)
    end
  end
end
