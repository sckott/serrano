require "faraday"
require "faraday_middleware"
require "multi_json"
require "serrano/errors"
require "serrano/constants"
require 'serrano/helpers/configuration'

##
# Serrano::CNRequest
#
# Class to perform HTTP requests to the Crossref API
module Serrano
  class CNRequest #:nodoc:

    attr_accessor :ids
    attr_accessor :format
    attr_accessor :style
    attr_accessor :locale

    def initialize(ids, format, style, locale)
      self.ids = ids
      self.format = format
      self.style = style
      self.locale = locale
    end

    def perform
      if !$cn_formats.include? self.format
        raise "format not one of accepted types"
      end

      $conn = Faraday.new "http://dx.doi.org/" do |c|
        c.use FaradayMiddleware::FollowRedirects
        c.adapter :net_http
      end

      if self.ids.length == 1
        return make_request(self.ids, self.format, self.style, self.locale)
      else
        coll = []
        Array(self.ids).each do |x|
          coll << make_request(x, self.format, self.style, self.locale)
        end
        return coll
      end
    end
  end
end

def make_request(ids, format, style, locale)
  type = $cn_format_headers.select { |x, _| x.include? format }.values[0]

  if format == "citeproc-json"
    endpt = "http://api.crossref.org/works/" + ids + "/" + type
    cr_works = Faraday.new(:url => endpt)
    res = cr_works.get
  else
    if format == "text"
      type = type + "; style = " + style + "; locale = " + locale
    end

    res = $conn.get do |req|
      req.url ids
      req.headers['Accept'] = type
    end
  end

  return res.body
end

# parser <- cn_types[[self.format]]
# if (raw) {
#   content(response, "text")
# } else {
#   out <- content(response, "parsed", parser, "UTF-8")
#   if (format == "text") {
#     out <- gsub("\n", "", out)
#   }
#   if (format == "bibentry") {
#     out <- parse_bibtex(out)
#   }
#   out
# }
