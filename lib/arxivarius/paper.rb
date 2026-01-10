# frozen_string_literal: true

module Arxivarius
  class Paper
    include HappyMapper

    tag 'entry'
    element :arxiv_url, String, tag: 'id'
    element :created_at, Time, tag: 'published'
    element :updated_at, Time, tag: 'updated'
    element :title, Text, parser: :squish
    element :summary, Text, parser: :squish
    element :comment, Text, parser: :squish
    has_one :primary_category, Category
    has_many :categories, Category
    has_many :authors, Author
    has_many :links, Link

    alias_method :abstract, :summary

    def arxiv_url
      force_https(@arxiv_url)
    end

    def revision?
      created_at != updated_at
    end

    def legacy_article?
      arxiv_url.match?(Arxivarius::LEGACY_URL_FORMAT)
    end

    def arxiv_id
      arxiv_versioned_id.match(/([^v]+)v\d+$/)[1]
    end

    def arxiv_versioned_id
      @arxiv_versioned_id ||= if legacy_article?
        arxiv_url.match(/(#{Arxivarius::LEGACY_URL_FORMAT})/)[1]
      else
        arxiv_url.match(/(#{Arxivarius::CURRENT_URL_FORMAT})/)[1]
      end
    end

    def version
      arxiv_url.match(/v(\d+)$/)[1].to_i
    end

    def content_types
      @content_types ||= links.map(&:content_type).compact.grep_v(/^\s*$/)
    end

    def available_in_pdf?
      content_types.any? { |type| type == 'application/pdf' }
    end

    def pdf_url
      link = links.find { |l| l.content_type == 'application/pdf' }
      force_https(link.url) if link
    end

    private

    def force_https(url)
      url.sub(/^http:/, 'https:')
    end
  end
end
