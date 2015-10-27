require "serrano/version"
require "cnrequest"

##
# CN - Content Negotiation
#
# @see http://www.crosscite.org/cn/ for details
module Serrano
  module CN

    ##
    # Get citations in various formats from CrossRef
    #
    # @param ids [String] DOIs
    # @param format [String] Format
    # @param style [String] Style
    # @param locale [String] Locale
    # @return [Hash] A hash
    #
    # @example
    #     require 'serrano'
    #     # By default, you get bibtex, apa format, in en-US locale
    #     Serrano.cn(ids: '10.1126/science.169.3946.635')
    #     # get citeproc-json
    #     Serrano.cn(ids: '10.1126/science.169.3946.635', format: "citeproc-json")
    def self.cn(ids:, format: "bibtex", style: 'apa', locale: "en-US")
      CNRequest.new(ids, format, style, locale).perform
    end

  end
end
