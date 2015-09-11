require "faraday"

##
# Crossref::Request
#
# Class to perform HTTP requests to the Crossref API
module Crossref
  class Request #:nodoc:
    $crbase = "http://api.crossref.org/"

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

    def initialize(endpt, id, query, filter, offset,
      limit, sample, sort, order, facet, works)

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
    end

    def perform
      # url = $crbase + self.endpt

      filt = filter_handler(self.filter)

      args = { query: self.query, filter: filt, offset: self.offset,
              rows: self.limit, sample: self.sample, sort: self.sort,
              order: self.order, facet: self.facet }
      options = args.delete_if { |k, v| v.nil? }

      conn = Faraday.new(:url => $crbase)

      if self.id.nil?
        # res = HTTParty.get(url, options)
        res = conn.get self.endpt, options
        return res
      else
        coll = []
        Array(self.id).each do |x|
          if works
            endpt = self.endpt + '/' + x.to_s + "/works"
          else
            endpt = self.endpt + '/' + x.to_s
          end
          # coll << HTTParty.get(url, options)
          res = conn.get endpt, options
          coll << res
        end
        return coll
      end
    end
  end
end
