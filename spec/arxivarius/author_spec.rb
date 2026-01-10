# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Arxivarius::Author, vcr: '2601.00470' do
  let(:author) { Arxivarius.get('2601.00470').authors.first }

  describe 'name' do
    it "returns the author's name" do
      expect(author.name).to eql('Andrea K. Dupree')
    end
  end

  describe 'first_name' do
    it "returns the author's first name" do
      expect(author.first_name).to eql('Andrea K.')
    end
  end

  describe 'last_name' do
    it "returns the author's last name" do
      expect(author.last_name).to eql('Dupree')
    end
  end

  describe 'affiliations' do
    it "returns an array of the author's affiliations" do
      expect(author.affiliations).to include('Center for Astrophysics | Harvard & Smithsonian, Cambridge, USA')
    end
  end
end
