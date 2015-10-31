require "nokogiri"

##
# Serrano::Mined
#
# Class to give back text mining object
module Serrano
  class Mined #:nodoc:
    attr_accessor :url
    attr_accessor :path
    attr_accessor :type

    def initialize(url, path, type)
      self.url = url
      self.path = path
      self.type = type
    end

    def parse
      case self.type
      when 'xml'
        parse_xml(self.path)
      when 'plain'
        parse_plain(self.path)
      when 'pdf'
        parse_pdf(self.path)
      end
    end

  end
end
