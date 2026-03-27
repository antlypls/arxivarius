# frozen_string_literal: true

require 'spec_helper'

RSpec::Matchers.define :fetch do |expected|
  match do |actual|
    actual.is_a?(Arxivarius::Paper) && actual.title == expected
  end
end

RSpec.describe Arxivarius do
  describe '.normalize_legacy_id' do
    it 'strips subcategory from legacy ids' do
      expect(Arxivarius.send(:normalize_legacy_id, 'math.DG/0510097')).to eql('math/0510097')
    end

    it 'strips subcategory from legacy ids with version' do
      expect(Arxivarius.send(:normalize_legacy_id, 'math.DG/0510097v1')).to eql('math/0510097v1')
    end

    it 'leaves legacy ids without subcategory unchanged' do
      expect(Arxivarius.send(:normalize_legacy_id, 'hep-th/9901001')).to eql('hep-th/9901001')
    end

    it 'leaves current format ids unchanged' do
      expect(Arxivarius.send(:normalize_legacy_id, '2601.00470')).to eql('2601.00470')
    end
  end

  describe '.get' do
    context 'when using the current arXiv id format' do
      it 'fetches a paper when passed an id', vcr: '2601.00470' do
        expect(Arxivarius.get('2601.00470')).to fetch('Betelgeuse: Detection of the Expanding Wake of the Companion Star')
      end

      it 'fetches a paper when passed a valid id with a version number', vcr: '2601.00470v1' do
        expect(Arxivarius.get('2601.00470v1')).to fetch('Betelgeuse: Detection of the Expanding Wake of the Companion Star')
      end

      it 'fetches a paper when passed full URL', vcr: '2601.00470' do
        expect(Arxivarius.get('https://arxiv.org/abs/2601.00470')).to fetch('Betelgeuse: Detection of the Expanding Wake of the Companion Star')
      end

      it 'fetches a paper when passed an id with more than 4 digits', vcr: '1509.06369' do
        expect(Arxivarius.get('1509.06369')).to fetch('Tidal debris morphology and the orbits of satellite galaxies')
      end
    end

    context 'when using the legacy arXiv id format' do
      it 'fetches a paper when passed an id', vcr: 'hep-th_9901001' do
        expect(Arxivarius.get('hep-th/9901001')).to fetch('String Junctions and Their Duals in Heterotic String Theory')
      end

      it 'fetches a paper when passed a valid id with a version number', vcr: 'hep-th_9901001v3' do
        expect(Arxivarius.get('hep-th/9901001v3')).to fetch('String Junctions and Their Duals in Heterotic String Theory')
      end

      it 'fetches a paper when passed full URL', vcr: 'hep-th_9901001' do
        expect(Arxivarius.get('https://arxiv.org/abs/hep-th/9901001')).to fetch('String Junctions and Their Duals in Heterotic String Theory')
      end

      it 'normalizes subcategory legacy ids', vcr: 'math_0510097' do
        expect(Arxivarius.get('math.DG/0510097')).to fetch('The differential topology of loop spaces')
      end
    end

    context 'when something goes wrong' do
      it 'raises an error if the paper cannot be found on arXiv', vcr: '1234.1234' do
        expect { Arxivarius.get('1234.1234') }.to raise_error(Arxivarius::Error::PaperNotFound)
      end

      it 'raises an error if the paper has an incorrectly formatted id' do
        expect { Arxivarius.get('cond-mat0709123') }.to raise_error(Arxivarius::Error::MalformedId)
      end

      it 'raises an error on HTTP 429 rate limit', vcr: 'rate_limit_429' do
        expect { Arxivarius.get('2601.00470') }.to raise_error(
          Arxivarius::Error::ApiError, /429.*Rate exceeded/
        )
      end

      it 'raises an error on HTTP 500 server error', vcr: 'server_error_500' do
        expect { Arxivarius.get('2601.00470') }.to raise_error(
          Arxivarius::Error::ApiError, /500.*Internal Server Error/
        )
      end
    end
  end
end
