# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arxivarius::WebSource do
  describe 'scraping a current paper', vcr: 'web_2601.00470' do
    let(:paper) { Arxivarius.get('2601.00470', source: :web) }

    it 'returns a Paper' do
      expect(paper).to be_a(Arxivarius::Paper)
    end

    it 'fetches the arxiv_id' do
      expect(paper.arxiv_id).to eql('2601.00470')
    end

    it 'fetches the title' do
      expect(paper.title).to eql('Betelgeuse: Detection of the Expanding Wake of the Companion Star')
    end

    it 'fetches the abstract' do
      expect(paper.abstract).to start_with('Recent analyses conclude that Betelgeuse')
    end

    it 'fetches the comment' do
      expect(paper.comment).to eql('20 pages + 1 appendix, 9 figures, accepted by ApJ')
    end

    it 'fetches the published date' do
      expect(paper.created_at).to eql(Time.parse('2026-01-01T20:56:05Z'))
    end

    it 'fetches the updated date' do
      expect(paper.updated_at).to eql(Time.parse('2026-01-01T20:56:05Z'))
    end

    it 'reports the version' do
      expect(paper.version).to be(1)
    end

    it 'is not a revision' do
      expect(paper).not_to be_revision
    end

    it 'is not a legacy article' do
      expect(paper).not_to be_legacy_article
    end

    it 'fetches the authors' do
      expect(paper.authors.map(&:name)).to eql(
        ['Andrea K. Dupree', 'Paul I. Cristofari', 'Morgan MacLeod', 'Kateryna Kravchenko']
      )
    end

    it 'derives the author first name' do
      expect(paper.authors.first.first_name).to eql('Andrea K.')
    end

    it 'derives the author last name' do
      expect(paper.authors.first.last_name).to eql('Dupree')
    end

    it 'leaves affiliations empty (not on the abstract page)' do
      expect(paper.authors.first.affiliations).to eql([])
    end

    it 'fetches the categories' do
      expect(paper.categories.map(&:name)).to contain_exactly('astro-ph.SR', 'physics.space-ph')
    end

    it 'fetches the primary category' do
      expect(paper.primary_category.name).to eql('astro-ph.SR')
    end

    it 'resolves the category description from the local mapping' do
      expect(paper.primary_category.description).to eql('Solar and Stellar Astrophysics')
    end

    it 'reports the content types' do
      expect(paper.content_types).to contain_exactly('application/pdf', 'text/html')
    end

    it 'is available in pdf' do
      expect(paper).to be_available_in_pdf
    end

    it 'builds a versioned pdf_url' do
      expect(paper.pdf_url).to eql('https://arxiv.org/pdf/2601.00470v1')
    end

    it 'fetches the versioned arxiv_url' do
      expect(paper.arxiv_url).to eql('https://arxiv.org/abs/2601.00470v1')
    end
  end

  describe 'scraping a revised legacy paper', vcr: 'web_hep-th_9901001' do
    let(:paper) { Arxivarius.get('hep-th/9901001', source: :web) }

    it 'fetches the legacy arxiv_id' do
      expect(paper.arxiv_id).to eql('hep-th/9901001')
    end

    it 'fetches the title' do
      expect(paper.title).to eql('String Junctions and Their Duals in Heterotic String Theory')
    end

    it 'reports the latest version' do
      expect(paper.version).to be(3)
    end

    it 'is a revision' do
      expect(paper).to be_revision
    end

    it 'is a legacy article' do
      expect(paper).to be_legacy_article
    end

    it 'fetches the first-submitted date' do
      expect(paper.created_at).to eql(Time.parse('1999-01-01T01:01:10Z'))
    end

    it 'fetches the last-revised date' do
      expect(paper.updated_at).to eql(Time.parse('1999-05-10T04:45:54Z'))
    end
  end

  describe 'when the paper does not exist', vcr: 'web_1234.1234' do
    it 'raises PaperNotFound' do
      expect { Arxivarius.get('1234.1234', source: :web) }.to raise_error(
        Arxivarius::Error::PaperNotFound
      )
    end
  end
end
