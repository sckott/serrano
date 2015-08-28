module Crossref
  class Request #:nodoc:
    include HTTParty
    debug_output $stdout # <= this is it!

    $crbase = "http://api.crossref.org/"

    attr_accessor :endpt
    attr_accessor :doi
    attr_accessor :query

    def initialize(endpt, doi, query)
      self.endpt = endpt
      self.doi = doi
      self.query = query
    end

    def perform
      url = $crbase + self.endpt

      args = {"query" => self.query}
      args = args.delete_if { |k, v| v.nil? }

      if doi.nil?
        # puts args
        # puts url
        res = HTTParty.get(url, :query => args)
        return res
      else
        coll = []
        Array(self.doi).each do |x|
          coll << HTTParty.get(url + '/' + x)
        end
        return coll
      end
    end
  end
end
