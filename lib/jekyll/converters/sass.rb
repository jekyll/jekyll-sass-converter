require 'sass'
require 'jekyll/utils'

module Jekyll
  module Converters
    class Sass < Scss
      safe true
      priority :low

      def matches(ext)
        ext =~ /^\.sass$/i
      end

      def sass_syntax(content)
        :sass
      end
    end
  end
end
