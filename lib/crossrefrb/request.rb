module Crossref
  class Request #:nodoc:
    attr_accessor :endpt
    attr_accessor :doi

    def initialize(endpt, doi)
      self.endpt = endpt
      self.doi = doi
    end

    def perform
      url = "http://api.crossref.org/" + self.endpt
      coll = []
      Array(self.doi).each do |x|
        puts url + '/' + x
        # coll << HTTParty.get(url + '/' + x)
      end
      return coll
    end
  end
end
