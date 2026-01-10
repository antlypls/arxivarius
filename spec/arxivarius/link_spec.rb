# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arxivarius::Link, vcr: '2601.00470' do
  let(:paper) { Arxivarius.get('2601.00470') }
  let(:pdf_link) { paper.links.find { |l| l.content_type == 'application/pdf' } }

  describe 'content_type' do
    it "fetches the link's content type" do
      expect(pdf_link.content_type).to eql('application/pdf')
    end
  end

  describe 'url' do
    it "fetches the link's url" do
      expect(pdf_link.url).to eql('https://arxiv.org/pdf/2601.00470v1')
    end
  end
end
