# frozen_string_literal: true

require "fileutils"
require "jekyll"

lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll-sass-converter"

Jekyll.logger.log_level = :error

module GlobalSharedContext
  extend RSpec::SharedContext

  SASS_IMPLEMENTATION = ENV["SASS_IMPLEMENTATION"]&.to_sym

  let(:sass_implementation) do
    SASS_IMPLEMENTATION
  end
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"

  config.include GlobalSharedContext
  config.before(:example) do
    if sass_implementation
      allow_any_instance_of(Jekyll::Converters::Scss)
        .to(receive(:sass_implementation).and_return(sass_implementation))
    end
  end

  SOURCE_DIR   = File.expand_path("source", __dir__)
  DEST_DIR     = File.expand_path("dest",   __dir__)
  SASS_LIB_DIR = File.expand_path("other_sass_library", __dir__)
  FileUtils.rm_rf(DEST_DIR)
  FileUtils.mkdir_p(DEST_DIR)

  def source_dir(*files)
    File.join(SOURCE_DIR, *files)
  end

  def dest_dir(*files)
    File.join(DEST_DIR, *files)
  end

  def sass_lib(*files)
    File.join(SASS_LIB_DIR, *files)
  end

  def site_configuration(overrides = {})
    Jekyll.configuration(
      overrides.merge(
        "source"      => source_dir,
        "destination" => dest_dir
      )
    )
  end

  # rubocop:disable Style/StringConcatenation
  def compressed(content)
    content.gsub(%r!\s+!, "").gsub(%r!;}!, "}") + "\n"
  end
  # rubocop:enable Style/StringConcatenation

  def make_site(config)
    Jekyll::Site.new(site_configuration.merge(config))
  end

  def scss_converter_instance(site)
    site.find_converter_instance(Jekyll::Converters::Scss)
  end

  def sass_converter_instance(site)
    site.find_converter_instance(Jekyll::Converters::Sass)
  end

  def create_directory(location)
    FileUtils.mkdir_p(location) unless File.directory?(location)
  end

  def remove_directory(location)
    FileUtils.rmdir(location) if File.directory?(location)
  end
end
