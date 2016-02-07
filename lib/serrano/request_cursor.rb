require "faraday"
require "multi_json"
require "serrano/errors"
require "serrano/constants"
require 'serrano/helpers/configuration'

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
    attr_accessor :works
    attr_accessor :agency
    attr_accessor :options
    attr_accessor :verbose
    attr_accessor :cursor
    attr_accessor :cursor_max

    def initialize(endpt, id, query, filter, offset,
      limit, sample, sort, order, facet, works, agency,
      options, verbose, cursor, cursor_max)

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
      self.works = works
      self.agency = agency
      self.options = options
      self.verbose = verbose
      self.cursor = cursor
      self.cursor_max = cursor_max
    end

    def perform
      filt = filter_handler(self.filter)

      if self.cursor_max.class != nil
        if self.cursor_max.class != Fixnum
          raise "cursor_max must be of class int"
        end
      end

      args = { query: self.query, filter: filt, offset: self.offset,
              rows: self.limit, sample: self.sample, sort: self.sort,
              order: self.order, facet: self.facet, cursor: self.cursor }
      opts = args.delete_if { |k, v| v.nil? }

      if verbose
        conn = Faraday.new(:url => Serrano.base_url, :request => options) do |f|
          f.response :logger
          f.adapter  Faraday.default_adapter
        end
      else
        conn = Faraday.new(:url => Serrano.base_url, :request => options)
      end

      js = self._req(conn, opts)
      cu = js['message'].get('next-cursor')
      max_avail = js['message']['total-results']
      res = self._redo_req(js, payload, cu, max_avail)
      return res
    end

    def _redo_req(js, payload, cu, max_avail)
      if is_not_none(cu) and self.cursor_max > js['message']['items'].length
        res = [js]
        total = len(js['message']['items'])
        while cu.__class__.__name__ != 'NoneType' and self.cursor_max > total and total < max_avail do
          payload['cursor'] = cu
          out = self._req(payload = payload)
          cu = out['message'].get('next-cursor')
          res.append(out)
          total = sum([ len(z['message']['items']) for z in res ])
        end
        return res
      else
        return js
      end
    end

    def _req(conn, path, opts)
      res = conn.get path, opts
      return MultiJson.load(res.body)
    end
  end
end
