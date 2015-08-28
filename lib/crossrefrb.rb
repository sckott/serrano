require 'httparty'
require 'json'
require "crossrefrb/version"
require "crossrefrb/request"

module Crossref
  ##
  # Search the works API
  #
  # @param doi [Array] A DOI, digital object identifier
  # @return [Array] the output
  #
  # @example
  #     require 'crossref'
  #     # Search by DOI, one or more
  #     Crossref.works('10.5555/515151')
  #     Crossref.works('10.1371/journal.pone.0033693')
  #     Crossref.works(['10.1007/12080.1874-1746','10.1007/10452.1573-5125', '10.1111/(issn)1442-9993'])
  def self.works(doi)
    Request.new('works', doi).perform
  end

end
