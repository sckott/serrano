require "faraday"
require "multi_json"
require "serrano/errors"
require "serrano/constants"
require 'serrano/helpers/configuration'

##
# Serrano::Request
#
# Class to perform HTTP requests to the Crossref API
module Serrano
  class Request #:nodoc:

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

    def initialize(endpt, id, query, filter, offset,
      limit, sample, sort, order, facet, works, agency,
      options, verbose)

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
    end

    def perform
      filt = filter_handler(self.filter)

      args = { query: self.query, filter: filt, offset: self.offset,
              rows: self.limit, sample: self.sample, sort: self.sort,
              order: self.order, facet: self.facet }
      opts = args.delete_if { |k, v| v.nil? }

      if verbose
        conn = Faraday.new(:url => Serrano.base_url, :request => options) do |f|
          f.response :logger
          f.adapter  Faraday.default_adapter
        end
      else
        conn = Faraday.new(:url => Serrano.base_url, :request => options)
      end

      if self.id.nil?
        # begin
        res = conn.get self.endpt, opts
        return MultiJson.load(res.body)
        # rescue *NETWORKABLE_EXCEPTIONS => e
        #   rescue_faraday_error(endpt, e)
        # end
      else
        coll = []
        Array(self.id).each do |x|
          if self.works
            endpt = self.endpt + '/' + x.to_s + "/works"
          else
            if self.agency
              endpt = self.endpt + '/' + x.to_s + "/agency"
            else
              endpt = self.endpt + '/' + x.to_s
            end
          end

          res = conn.get endpt, opts
          coll << MultiJson.load(res.body)
          # begin
          #   res = conn.get endpt, opts
          #   coll << MultiJson.load(res.body)
          # rescue *NETWORKABLE_EXCEPTIONS => e
          #   rescue_faraday_error(endpt, e)
          # end
        end
        return coll
      end
    end
  end
end
