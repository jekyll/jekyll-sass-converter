require 'sass'
require 'jekyll/utils'

module Jekyll
  module Converters
    class Scss < Converter
      SyntaxError = Class.new(ArgumentError)

      safe true
      priority :low

      ALLOWED_STYLES = %w(nested expanded compact compressed).freeze

      def matches(ext)
        ext =~ /^\.scss$/i
      end

      def output_ext(ext)
        ".css"
      end

      def safe?
        !!@config["safe"]
      end

      def jekyll_sass_configuration
        options = @config["sass"] || {}
        unless options["style"].nil?
          options["style"] = options["style"].to_s.gsub(/\A:/, '').to_sym
        end
        options
      end

      def sass_build_configuration_options(overrides)
        if safe?
          {
            :load_paths => sass_load_paths,
            :syntax     => syntax,
            :style      => sass_style,
            :cache      => false
          }
        else
          Jekyll::Utils.symbolize_hash_keys(
            Jekyll::Utils.deep_merge_hashes(
              jekyll_sass_configuration,
              overrides
            )
          )
        end
      end

      def syntax
        :scss
      end

      def sass_dir
        return "_sass" if jekyll_sass_configuration["sass_dir"].to_s.empty?
        jekyll_sass_configuration["sass_dir"]
      end

      def sass_style
        style = jekyll_sass_configuration.fetch("style", :compact)
        ALLOWED_STYLES.include?(style.to_s) ? style.to_sym : :compact
      end

      def user_sass_load_paths
        Array(jekyll_sass_configuration["load_paths"])
      end

      def compass_sass_load_paths
        require 'compass'
        Compass.configuration.sass_load_paths
      rescue LoadError
        []
      end

      def sass_dir_relative_to_site_source
        Jekyll.sanitized_path(@config["source"], sass_dir)
      end

      def sass_load_paths
        if safe?
          [sass_dir_relative_to_site_source]
        else
          (user_sass_load_paths + [sass_dir_relative_to_site_source]).uniq +
            compass_sass_load_paths
        end.select { |load_path|
          !load_path.is_a?(String) || File.directory?(load_path)
        }
      end

      def allow_caching?
        !safe?
      end

      def sass_configs
        sass_build_configuration_options({
          "syntax"     => syntax,
          "cache"      => allow_caching?,
          "load_paths" => sass_load_paths
        })
      end

      def convert(content)
        ::Sass.compile(content, sass_configs)
      rescue ::Sass::SyntaxError => e
        raise SyntaxError.new("#{e.to_s} on line #{e.sass_line}")
      end
    end
  end
end
