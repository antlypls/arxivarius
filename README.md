# ArXivarius

A Ruby gem for fetching paper metadata from the [arXiv](https://arxiv.org/).
Retrieve titles, abstracts, authors, categories, and links for any paper on arXiv.

## Installation

Add to your Gemfile:

```ruby
gem 'arxivarius'
```

Or install directly:

```
gem install arxivarius
```

## Usage

### Fetching a paper

Pass any arXiv ID to `Arxivarius.get`:

```ruby
paper = Arxivarius.get('2601.00470')
```

All common ID formats work:

```ruby
Arxivarius.get('2601.00470')                        # current format
Arxivarius.get('2601.00470v1')                      # with version
Arxivarius.get('hep-th/9901001')                    # legacy format
Arxivarius.get('math.DG/0510097')                   # legacy with subcategory (auto-normalized)
Arxivarius.get('https://arxiv.org/abs/2601.00470')  # full URL
```

### Paper metadata

```ruby
paper.title       # => "Betelgeuse: Detection of the Expanding Wake of the Companion Star"
paper.abstract    # => "Recent analyses conclude that Betelgeuse, a red supergiant star..."
paper.comment     # => "20 pages + 1 appendix, 9 figures, accepted by ApJ"
paper.arxiv_url   # => "https://arxiv.org/abs/2601.00470v1"
paper.created_at  # => 2026-01-01 20:56:05 UTC
paper.updated_at  # => 2026-01-01 20:56:05 UTC
```

### IDs and versions

```ruby
paper.arxiv_id            # => "2601.00470"
paper.arxiv_versioned_id  # => "2601.00470v1"
paper.version             # => 1
paper.revision?           # => false (true when the paper has been updated)
paper.legacy_article?     # => false (true for pre-2007 IDs like hep-th/9901001)
```

### PDF access

```ruby
paper.available_in_pdf?  # => true
paper.pdf_url            # => "https://arxiv.org/pdf/2601.00470v1"
paper.content_types      # => ["text/html", "application/pdf"]
```

### Links

Each paper has a list of links with URLs and content types:

```ruby
paper.links.each do |link|
  link.url           # => "https://arxiv.org/pdf/2601.00470v1"
  link.content_type  # => "application/pdf"
end
```

### Authors

```ruby
paper.authors.map(&:name)
# => ["Andrea K. Dupree", "Paul I. Cristofari", "Morgan MacLeod", "Kateryna Kravchenko"]

author = paper.authors.first
author.name          # => "Andrea K. Dupree"
author.first_name    # => "Andrea K."
author.last_name     # => "Dupree"
author.affiliations  # => ["Center for Astrophysics | Harvard & Smithsonian, Cambridge, USA"]
```

### Categories

The gem includes descriptions for all 150+ arXiv categories:

```ruby
paper.categories.map(&:name)  # => ["astro-ph.SR", "physics.space-ph"]

cat = paper.primary_category
cat.name              # => "astro-ph.SR"
cat.description       # => "Solar and Stellar Astrophysics"
cat.long_description  # => "astro-ph.SR (Solar and Stellar Astrophysics)"
```

## Error handling

```ruby
begin
  paper = Arxivarius.get('2601.00470')
rescue Arxivarius::Error::PaperNotFound
  # paper does not exist on arXiv
rescue Arxivarius::Error::MalformedId
  # the ID format is invalid
end
```

## Credits

ArXivarius is based on the outdated [arxiv](https://rubygems.org/gems/arxiv) gem.
Arxivarius picks up where it left off, with updated dependencies and a few improvements.

## License

MIT
