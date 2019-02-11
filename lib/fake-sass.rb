# frozen_string_literal: true

# This module helps to get rid of the now deprecated
# [ruby-sass](https://github.com/sass/ruby-sass).
#
# Some modules used in jekyll depend on the function `Sass.load_paths`
# from ruby-sass. (see for example `Jekyll::Theme.configure_sass`).
#
# This module provides a workaround when ruby-sass is not installed
# by faking this functionality...
#
# Please note that this module should never be installed __together__ with ruby-sass.
#
#
module Sass
  # The global load paths for Sass files. This is meant for plugins and
  # libraries to register the paths to their Sass stylesheets to that they may
  # be `@imported`. This load path is used by every instance of {Sass::Engine}.
  # They are lower-precedence than any load paths passed in via the
  # {file:SASS_REFERENCE.md#load_paths-option `:load_paths` option}.
  #
  # If the `SASS_PATH` environment variable is set,
  # the initial value of `load_paths` will be initialized based on that.
  # The variable should be a colon-separated list of path names
  # (semicolon-separated on Windows).
  #
  # Note that files on the global load path are never compiled to CSS
  # themselves, even if they aren't partials. They exist only to be imported.
  #
  # @example
  #   Sass.load_paths << File.dirname(__FILE__ + '/sass')
  # @return [Array<String, Pathname, Sass::Importers::Base>]
  def self.load_paths
    @load_paths ||= ENV["SASS_PATH"].to_s.split(File::PATH_SEPARATOR)
  end
end
