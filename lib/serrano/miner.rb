require "faraday"
require "multi_json"
require "serrano/errors"
require "serrano/constants"
require 'serrano/helpers/configuration'
require 'serrano/mined'
require 'serrano/mine_utils'

##
# Serrano::Miner
#
# Class to give back text mining object
module Serrano
  class Miner #:nodoc:
    attr_accessor :url
    attr_accessor :type

    def initialize(url, type)
      self.url = url
      self.type = type
    end

    def perform
      conn = Faraday.new(:url => self.url)

      if is_elsevier(self.url)
        res = conn.get do |req|
          req.headers['X-ELS-APIKey'] = Serrano.elsevier_key
        end
      else
        res = conn.get
      end

      type = detect_type(res)
      path = make_path(type)
      write_disk(res, path)

      return Mined.new(self.url, path, type)
    end

  end
end
