# frozen_string_literal: true

require_relative 'lib/arxivarius/version'

Gem::Specification.new do |s|
  s.name        = 'arxivarius'
  s.version     = Arxivarius::VERSION
  s.authors     = ['antlypls']
  s.email       = ['hello@antlypls.com']
  s.homepage    = 'https://github.com/antlypls/arxivarius'
  s.summary     = 'Fetch and parse papers metadata from arXiv'
  s.description = 'Look up any arXiv paper by ID or URL and get structured metadata: ' \
                  'titles, authors, abstracts, categories, and PDF links.'
  s.licenses    = ['MIT']

  s.required_ruby_version = '>= 3.2'

  s.files         = Dir['lib/**/*', 'README.md', 'LICENSE']
  s.require_paths = ['lib']

  s.add_dependency 'full-name-splitter', '~> 0.1.2'
  s.add_dependency 'nokogiri-happymapper', '~> 0.10'
end
