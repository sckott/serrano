# frozen_string_literal: true

require "serrano/version"
require "serrano/cnrequest"

##
# ContentNegotiation - Content Negotiation class
#
# @see https://citation.crosscite.org/docs.html for details
module Serrano
  class ContentNegotiation
    attr_accessor :ids
    attr_accessor :format
    attr_accessor :style
    attr_accessor :locale

    def initialize(ids, format = "bibtex", style = "apa", locale = "en-US")
      self.ids = ids
      self.format = format
      self.style = style
      self.locale = locale
    end

    def cn
      CNRequest.new(ids, format, style, locale).perform
    end
  end
end
