require 'faraday'
require 'faraday_middleware'
require 'multi_json'
require 'serrano/error'
require 'serrano/constants'
require 'serrano/utils'
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
      unless $cn_formats.include? format
        raise 'format not one of accepted types'
      end

      $conn = Faraday.new 'https://doi.org/' do |c|
        c.use FaradayMiddleware::FollowRedirects
        c.adapter :net_http
      end

      if ids.length == 1
        self.ids = ids[0] if ids.class == Array
        return make_request(ids, format, style, locale)
      else
        coll = []
        Array(ids).each do |x|
          coll << make_request(x, format, style, locale)
        end
        return coll
      end
    end
  end
end

def make_request(ids, format, style, locale)
  type = $cn_format_headers.select { |x, _| x.include? format }.values[0]

  if format == 'citeproc-json'
    endpt = 'http://api.crossref.org/works/' + ids + '/' + type
    cr_works = Faraday.new(url: endpt)
    cr_works.headers[:user_agent] = make_ua
    cr_works.headers['X-USER-AGENT'] = make_ua
    res = cr_works.get
  else
    if format == 'text'
      type = type + '; style = ' + style + '; locale = ' + locale
    end

    res = $conn.get do |req|
      req.url ids
      req.headers['Accept'] = type
      req.headers[:user_agent] = make_ua
      req.headers['X-USER-AGENT'] = make_ua
    end
  end

  res.body
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
