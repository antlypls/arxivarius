# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arxivarius::Paper, vcr: '2601.00470' do
  let(:paper) { Arxivarius.get('2601.00470') }
  let(:legacy_manuscript) { Arxivarius.get('hep-th/9901001') }

  describe 'arxiv_url' do
    it "fetches the link to the paper's page on arXiv" do
      expect(paper.arxiv_url).to eql('https://arxiv.org/abs/2601.00470v1')
    end
  end

  describe 'created_at' do
    it 'fetches the datetime when the paper was first published to arXiv' do
      expect(paper.created_at).to eql(Time.parse('2026-01-01T20:56:05Z'))
    end
  end

  describe 'updated_at' do
    it 'fetches the datetime when the paper was last updated' do
      expect(paper.updated_at).to eql(Time.parse('2026-01-01T20:56:05Z'))
    end
  end

  describe 'title' do
    it "fetches the paper's title" do
      expect(paper.title).to eql('Betelgeuse: Detection of the Expanding Wake of the Companion Star')
    end
  end

  describe 'abstract' do
    it "fetches the paper's abstract" do
      expect(paper.abstract).to start_with('Recent analyses conclude that Betelgeuse')
    end
  end

  describe 'comment' do
    it "fetches the paper's comment" do
      expect(paper.comment).to eql('20 pages + 1 appendix, 9 figures, accepted by ApJ')
    end
  end

  describe 'revision?' do
    it 'returns true if the paper has been revised' do
      expect(paper).not_to be_revision
    end
  end

  describe 'arxiv_versioned_id' do
    it 'returns the unique versioned document id used by arXiv for a current paper' do
      expect(paper.arxiv_versioned_id).to eql('2601.00470v1')
    end

    it 'returns the unique versioned document id used by arXiv for a legacy paper', vcr: 'hep-th_9901001' do
      expect(legacy_manuscript.arxiv_versioned_id).to eql('hep-th/9901001v3')
    end
  end

  describe 'arxiv_id' do
    it 'returns the unique document id used by arXiv for a current paper' do
      expect(paper.arxiv_id).to eql('2601.00470')
    end

    it 'returns the unique document id used by arXiv for a legacy paper', vcr: 'hep-th_9901001' do
      expect(legacy_manuscript.arxiv_id).to eql('hep-th/9901001')
    end
  end

  describe 'version' do
    it "returns the paper's version number for a current paper" do
      expect(paper.version).to be(1)
    end

    it "returns the paper's version number for a legacy paper", vcr: 'hep-th_9901001' do
      expect(legacy_manuscript.version).to be(3)
    end
  end

  describe 'content_types' do
    it 'return an array of available content_types' do
      expect(paper.content_types).to contain_exactly('text/html', 'application/pdf')
    end
  end

  describe 'available_in_pdf?' do
    it 'returns true if the paper is available to be downloaded in PDF' do
      expect(paper).to be_available_in_pdf
    end
  end

  describe 'pdf_url' do
    it 'returns the url to download the paper in PDF format' do
      expect(paper.pdf_url).to eql('https://arxiv.org/pdf/2601.00470v1')
    end
  end

  describe 'authors' do
    it "returns an array of all the paper's authors" do
      expect(paper.authors.size).to be(4)
    end
  end

  describe 'categories' do
    it "fetches the paper's categories" do
      categories = paper.categories.map(&:name)
      expect(categories).to include('astro-ph.SR', 'physics.space-ph')
    end
  end

  describe 'primary_category' do
    it "returns the paper's primary category" do
      expect(paper.primary_category.name).to eql('astro-ph.SR')
    end
  end

  describe 'legacy_article?' do
    it 'returns true if the paper was upload while the legacy API was still in use', vcr: 'hep-th_9901001' do
      expect(legacy_manuscript).to be_legacy_article
    end

    it 'returns false if the paper was uploaded after the transition to the new API' do
      expect(paper).not_to be_legacy_article
    end
  end
end
