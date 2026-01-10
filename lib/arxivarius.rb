# frozen_string_literal: true

require 'net/http'
require 'time'
require 'nokogiri'
require 'happymapper'
require 'full-name-splitter'
require 'yaml'

require 'arxivarius/version'
require 'arxivarius/text'

require 'arxivarius/author'
require 'arxivarius/link'
require 'arxivarius/category'
require 'arxivarius/paper'

module Arxivarius
  module Error
    class PaperNotFound < StandardError; end
    class MalformedId < StandardError; end
  end

  # ArXiv uses two ID formats:
  #   Legacy:  math/0510097v1   (pre-2007)
  #   Current: 1202.0819v1      (2007+)
  LEGACY_URL_FORMAT = /[^\/]+\/\d+(?:v\d+)?$/
  CURRENT_URL_FORMAT = /\d{4,}\.\d{4,}(?:v\d+)?$/

  LEGACY_ID_FORMAT = /^#{LEGACY_URL_FORMAT}/
  ID_FORMAT = /^#{CURRENT_URL_FORMAT}/

  class << self
    def get(identifier)
      id = parse_arxiv_identifier(identifier)

      raise Arxivarius::Error::MalformedId, 'Paper ID format is invalid' unless valid_id?(id)

      id = normalize_legacy_id(id)

      url = URI("https://export.arxiv.org/api/query?id_list=#{id}")
      response = ::Nokogiri::XML(Net::HTTP.get(url)).remove_namespaces!
      paper = Arxivarius::Paper.parse(response.to_s, single: true)

      # Paper is nil when the API returns no <entry> for the given ID.
      raise Arxivarius::Error::PaperNotFound, "Paper #{id} doesn't exist on arXiv" unless paper&.title

      paper
    end

    private

    def parse_arxiv_identifier(identifier)
      if valid_url?(identifier)
        format = legacy_url?(identifier) ? LEGACY_URL_FORMAT : CURRENT_URL_FORMAT
        identifier.match(/(#{format})/)[1]
      else
        identifier
      end
    end

    def valid_id?(identifier)
      identifier.match?(ID_FORMAT) || identifier.match?(LEGACY_ID_FORMAT)
    end

    def valid_url?(identifier)
      identifier.match?(LEGACY_URL_FORMAT) || identifier.match?(CURRENT_URL_FORMAT)
    end

    def legacy_url?(identifier)
      identifier.match?(LEGACY_URL_FORMAT)
    end

    # The arXiv API no longer resolves subcategory legacy IDs.
    # Strips the subcategory: math.DG/0510097 -> math/0510097.
    def normalize_legacy_id(id)
      id.sub(/^([a-z-]+)\.[A-Z][A-Za-z]*\//, '\1/')
    end
  end
end
