require "faraday"
require 'faraday_middleware'
require "multi_json"
require "serrano/error"
require "serrano/constants"
require 'serrano/helpers/configuration'
require 'serrano/filterhandler'
require 'serrano/error'
require 'serrano/faraday'
require 'serrano/utils'

##
# Serrano::RequestCursor
#
# Class to perform HTTP requests to the Crossref API
module Serrano
  class RequestCursor #:nodoc:

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
      filt = filter_handler(self.filter)
      fieldqueries = field_query_handler(self.args)
      self.select = self.select.join(",") if self.select && self.select.class == Array

      if self.cursor_max.class != nil
        if !self.cursor_max.kind_of?(Integer)
          raise "cursor_max must be of class int"
        end
      end

      arguments = { query: self.query, filter: filt, offset: self.offset,
              rows: self.limit, sample: self.sample, sort: self.sort,
              order: self.order, facet: self.facet, select: self.select, 
              cursor: self.cursor }.tostrings
      arguments = arguments.merge(fieldqueries)
      opts = arguments.delete_if { |k, v| v.nil? }

      if verbose
        $conn = Faraday.new(:url => Serrano.base_url, :request => options || []) do |f|
          f.response :logger
          f.use FaradayMiddleware::RaiseHttpException
          f.adapter Faraday.default_adapter
        end
      else
        $conn = Faraday.new(:url => Serrano.base_url, :request => options || []) do |f|
          f.use FaradayMiddleware::RaiseHttpException
          f.adapter Faraday.default_adapter
        end
      end

      $conn.headers[:user_agent] = make_ua
      $conn.headers["X-USER-AGENT"] = make_ua

      if self.id.nil?
        $endpt2 = self.endpt
        js = self._req(self.endpt, opts)
        cu = js['message']['next-cursor']
        max_avail = js['message']['total-results']
        res = self._redo_req(js, opts, cu, max_avail)
        return res
      else
        coll = []
        Array(self.id).each do |x|
          if self.works
            $endpt2 = self.endpt + '/' + x.to_s + "/works"
          else
            if self.agency
              $endpt2 = self.endpt + '/' + x.to_s + "/agency"
            else
              $endpt2 = self.endpt + '/' + x.to_s
            end
          end

          js = self._req($endpt2, opts)
          cu = js['message']['next-cursor']
          max_avail = js['message']['total-results']
          coll << self._redo_req(js, opts, cu, max_avail)
        end
        return coll
      end
    end

    def _redo_req(js, opts, cu, max_avail)
      if !cu.nil? and self.cursor_max > js['message']['items'].length
        res = [js]
        total = js['message']['items'].length
        while !cu.nil? and self.cursor_max > total and total < max_avail do
          opts[:cursor] = cu
          out = self._req($endpt2, opts)
          cu = out['message']['next-cursor']
          res << out
          total = res.collect {|x| x['message']['items'].length}.reduce(0, :+)
        end
        return res
      else
        return js
      end
    end

    def _req(path, opts)
      res = $conn.get path, opts
      return MultiJson.load(res.body)
    end

  end
end
