# Override default importer to allow importing .css files.
#
# See https://github.com/sass/sass/issues/556
module Jekyll
  module Sass
    class Importer < ::Sass::Importers::Filesystem
      def extensions
        { 'css' => :scss }.merge(super)
      end
    end
  end
end
