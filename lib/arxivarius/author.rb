# frozen_string_literal: true

module Arxivarius
  class Author
    include HappyMapper

    element :name, Text, parser: :squish
    has_many :affiliations, Text, parser: :squish, tag: 'affiliation'

    def first_name = name_parts.first

    def last_name = name_parts.last

    private

    def name_parts
      @name_parts ||= FullNameSplitter.split(name)
    end
  end
end
