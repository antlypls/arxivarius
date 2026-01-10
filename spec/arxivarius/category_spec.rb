# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arxivarius::Category, vcr: '2601.00470' do
  let(:category) { Arxivarius.get('2601.00470').primary_category }

  describe 'name' do
    it "fetches the category's name" do
      expect(category.name).to eql('astro-ph.SR')
    end
  end

  describe 'description' do
    it "fetches the category's description" do
      expect(category.description).to eql('Solar and Stellar Astrophysics')
    end
  end

  describe 'long_description' do
    it "fetches the category's name and description" do
      expect(category.long_description).to eql('astro-ph.SR (Solar and Stellar Astrophysics)')
    end

    it 'returns only the name when a description cannot be found' do
      unknown = described_class.new
      unknown.instance_variable_set(:@name, 'cs.UNKNOWN')
      expect(unknown.long_description).to eql('cs.UNKNOWN')
    end
  end
end
