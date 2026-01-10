# frozen_string_literal: true

module Arxivarius
  module Text
    module_function

    def squish(string)
      string.tr("\n", ' ').strip.squeeze(' ')
    end
  end
end
