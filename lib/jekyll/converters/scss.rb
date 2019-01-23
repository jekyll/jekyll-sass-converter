# frozen_string_literal: true

require "sassc"
require "jekyll/utils"
require "jekyll/source_map_page"

module Jekyll
  module Converters
    class Scss < Converter
      BYTE_ORDER_MARK = %r!^\xEF\xBB\xBF!.freeze
      SyntaxError = Class.new(ArgumentError)

      safe true
      priority :low

      ##
      # This hook is triggered just before the method
      # {#convert(content)} is executed, it associates
      # the Scss (and Sass) converters with their
      # respective sass_page objects.
      Jekyll::Hooks.register :pages, :pre_render do |page|
        if page.respond_to? :converters
          page.converters.each do |converter|
            converter.associate_page(page) if converter.is_a?(Scss)
          end
        end
      end

      ##
      # This hook is triggered just after the method
      # {#convert(content)} is executed, it dissociates
      # the Scss (and Sass) converters with their
      # respective sass_page objects.
      Jekyll::Hooks.register :pages, :post_render do |page|
        if page.respond_to? :converters
          page.converters.each do |converter|
            converter.dissociate_page(page) if converter.is_a?(Scss)
          end
        end
      end

      ALLOWED_STYLES = %w(nested expanded compact compressed).freeze

      ##
      # Associate this Converter with the "page" object that manages
      # input and output files for this converter.
      #
      # Note: changing the associated sass_page-object during the live time of
      # this Converter-object may result in inconsistent results.
      #
      # @param [Jekyll:Page] page the sass_page-object for which this object acts as converter.
      def associate_page(page)
        if @sass_page
          Jekyll.logger.warn("Sass-converter",
                             "sass_page re-assigned: #{@sass_page.name} to #{page.name}")
          dissociate_page(page)
          return
        end
        @sass_page = page
      end

      ##
      # Dissociate this Converter with the "page" object.
      #
      # @param [Jekyll:Page] page the sass_page-object
      #                      for which this object has acted as a converter.
      def dissociate_page(page)
        unless page.equal?(@sass_page)
          Jekyll.logger.warn("Sass-converter",
                             "dissociating a page that was never associated #{page.name}")
        end

        @source_map_page = nil
        @sass_page = nil
        @site = nil
      end

      def associate_page_failed?
        !sass_page
      end

      # @attr_reader [Jekyll:Page] sass_page the Page-object for which this
      # object acts as a converter.
      attr_reader :sass_page

      def site
        sass_page.site unless associate_page_failed?
      end

      def source_map_page
        return if associate_page_failed?
        
        @source_map_page ||= SourceMapPage.new(sass_page)
      end

      def matches(ext)
        ext =~ %r!^\.scss$!i
      end

      def output_ext(_ext)
        ".css"
      end

      def safe?
        !!@config["safe"]
      end

      def jekyll_sass_configuration
        @jekyll_sass_configuration ||= begin
          options = @config["sass"] || {}
          unless options["style"].nil?
            options["style"] = options["style"].to_s.gsub(%r!\A:!, "").to_sym
          end
          options
        end
      end

      def sass_build_configuration_options(overrides)
        if safe?
          overrides
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

      def sass_dir_relative_to_site_source
        Jekyll.sanitized_path(site_source, sass_dir)
      end

      def sass_load_paths # rubocop:disable Metrics/AbcSize
        paths = user_sass_load_paths +
          [sass_dir_relative_to_site_source] +
          Array(::Sass.load_paths)

        if safe?
          # Sanitize paths to prevent any attack vectors (.e.g. `/**/*`)
          paths.map! { |path| Jekyll.sanitized_path(site_source, path) }
        end

        # Expand file globs (e.g. `node_modules/*/node_modules` )
        Dir.chdir(site_source) do
          paths = paths.map { |path| Dir.glob(path) }.flatten.uniq

          paths.map! do |path|
            if safe?
              # Sanitize again in case globbing was able to do something crazy.
              Jekyll.sanitized_path(site_source, path)
            else
              File.expand_path(path)
            end
          end
        end

        paths.select { |path| File.directory?(path) }
      end

      def allow_caching?
        !safe?
      end

      def add_charset?
        !!jekyll_sass_configuration["add_charset"]
      end

      # The name of the input scss (or sass) file.
      # This information will be used for error reporting
      # and will written into the source map file as main source.
      # @return [String] the name of the input file or
      #   "stdin" if #associate_page failed
      def filename
        return "stdin" if associate_page_failed?
        
        sass_page.name
      end

      # The name of the generated css file.
      # This information will be written into the
      # source map file as a backward reference to the input
      # @return [String] the name of the css file or
      #   "stdin.css" if #associate_page failed
      def output_path
        return "stdin.css" if associate_page_failed?
        
        sass_page.basename + ".css"
      end

      # The name of the generated source map file.
      # This information will be written into the
      # css file to reference to the source map.
      # @return [String] the name of the css file or
      #   "" if #associate_page failed
      def source_map_file
        return "" if associate_page_failed?
        
        sass_page.basename + ".css.map"
      end

      def sass_configs
        sass_build_configuration_options(
          :style               => sass_style,
          :syntax              => syntax,
          :filename            => filename,
          :output_path         => output_path,
          :source_map_file     => source_map_file,
          :load_paths          => sass_load_paths,
          :source_map_contents => true
        )
      end

      def convert(content)
        config = sass_configs
        config[:omit_source_map_url] = true if associate_page_failed?
        engine = ::SassC::Engine.new(content.dup, config)
        output = engine.render
        generate_source_map(engine)
        replacement = add_charset? ? '@charset "UTF-8";' : ""
        output.sub(BYTE_ORDER_MARK, replacement)
      rescue ::SassC::SyntaxError => e
        line = e.instance_variable_get(:@line)
        raise SyntaxError, "#{e} on line #{line}"
      end

      def generate_source_map(engine)
        return if associate_page_failed?
        
        source_map_page.source_map(engine.source_map)
        site.pages << source_map_page
      rescue ::SassC::NotRenderedError => e
        Jekyll.logger.warn("could not generate source map #{e.message} => #{e.cause}")
      end

      private

      def site_source
        @site_source ||= File.expand_path(@config["source"]).freeze
      end
    end
  end
end
