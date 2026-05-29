# frozen_string_literal: true

module Arxivarius
  # Builds a Paper by scraping the public arXiv abstract page
  # (https://arxiv.org/abs/<id>), used as an alternative to the Atom API when
  # it is rate limited. Reads the Highwire `citation_*` <meta> tags plus a few
  # body elements. Every field the API exposes is recovered except author
  # affiliations, which are not present on the abstract page.
  module WebSource
    ABS_URL = 'https://arxiv.org/abs/'
    PDF_URL = 'https://arxiv.org/pdf/'
    USER_AGENT = "arxivarius/#{Arxivarius::VERSION} " \
                 '(+https://github.com/antlypls/arxivarius)'.freeze

    class << self
      def fetch(id)
        doc = ::Nokogiri::HTML(fetch_html(id))

        # No citation_title means the page is not an abstract page (e.g. an
        # arXiv "identifier not recognized" page served with a 200 status).
        return nil unless meta(doc, 'citation_title')

        build_paper(doc)
      end

      private

      def fetch_html(id)
        url = URI("#{ABS_URL}#{id}")
        response = Net::HTTP.get_response(url, 'User-Agent' => USER_AGENT)

        return nil if response.is_a?(Net::HTTPNotFound)

        unless response.is_a?(Net::HTTPSuccess)
          message = "ArXiv returned #{response.code}: #{response.body&.strip}"
          raise Arxivarius::Error::ApiError, message
        end

        response.body
      end

      def build_paper(doc)
        Arxivarius::Paper.new.tap do |paper|
          apply_metadata(paper, doc)
          paper.created_at, paper.updated_at = submission_dates(doc)
          apply_associations(paper, doc)
        end
      end

      def apply_metadata(paper, doc)
        paper.arxiv_url = meta_property(doc, 'og:url')
        paper.title = squish(meta(doc, 'citation_title'))
        paper.summary = squish(meta(doc, 'citation_abstract'))
        paper.comment = comment(doc)
      end

      def apply_associations(paper, doc)
        paper.authors = authors(doc)
        paper.categories = categories(doc)
        paper.primary_category = primary_category(doc)
        paper.links = links(paper.arxiv_url)
      end

      # arXiv lists authors as "Last, First" in citation_author; reorder to
      # "First Last" so they match the Atom API output exactly.
      def authors(doc)
        meta_all(doc, 'citation_author').map do |raw|
          last, first = raw.split(',', 2).map { |part| squish(part) }
          name = first ? "#{first} #{last}" : last
          # Affiliations are not on the abstract page; match the API's empty
          # list rather than leaving them nil.
          Arxivarius::Author.new.tap do |author|
            author.name = name
            author.affiliations = []
          end
        end
      end

      def categories(doc)
        subjects = doc.at_css('td.subjects')&.text.to_s
        subjects.scan(/\(([^()]+)\)/).flatten.map do |code|
          build_category(code)
        end
      end

      def primary_category(doc)
        text = doc.at_css('.primary-subject')&.text.to_s
        code = text[/\(([^()]+)\)/, 1]
        build_category(code) if code
      end

      # Synthesize the link set the abstract page does not expose structurally,
      # so pdf_url, content_types and available_in_pdf? keep working. The PDF
      # link is versioned to match the Atom API (e.g. .../pdf/2601.00470v1).
      def links(arxiv_url)
        versioned_id = arxiv_url.split('/abs/', 2).last
        [
          build_link("#{PDF_URL}#{versioned_id}", 'application/pdf'),
          build_link(arxiv_url, 'text/html')
        ]
      end

      # The submission history lists every version's timestamp as
      # "[v1] Thu, 1 Jan 2026 20:56:05 UTC". The first is when the paper was
      # published, the last is when it was last revised.
      def submission_dates(doc)
        history = doc.at_css('.submission-history')&.text.to_s
        stamps = history.scan(/\[v\d+\]\s*(.+? UTC)/).flatten

        return [nil, nil] if stamps.empty?

        [Time.parse(stamps.first), Time.parse(stamps.last)]
      end

      def comment(doc)
        text = doc.at_css('td.comments')&.text
        squish(text) if text
      end

      def build_category(code)
        Arxivarius::Category.new.tap { |category| category.name = code }
      end

      def build_link(url, content_type)
        Arxivarius::Link.new.tap do |link|
          link.url = url
          link.content_type = content_type
        end
      end

      def meta(doc, name)
        doc.at_css("meta[name='#{name}']")&.[]('content')
      end

      def meta_all(doc, name)
        doc.css("meta[name='#{name}']").map { |tag| tag['content'] }
      end

      def meta_property(doc, property)
        doc.at_css("meta[property='#{property}']")&.[]('content')
      end

      def squish(string)
        Arxivarius::Text.squish(string)
      end
    end
  end
end
