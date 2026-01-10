# frozen_string_literal: true

module Arxivarius
  class Category
    include HappyMapper

    # Maps category names to human-readable labels.
    # Not available through the arXiv API, so we maintain a local copy.
    CATEGORIES_PATH = File.expand_path('data/categories.yml', __dir__)

    def self.types
      @types ||= YAML.safe_load_file(CATEGORIES_PATH)
    end

    attribute :name, String, tag: 'term'

    def description
      Category.types[name]
    end

    def long_description
      description ? "#{name} (#{description})" : name
    end
  end
end
