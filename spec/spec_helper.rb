# frozen_string_literal: true

require "fileutils"
require "jekyll"

lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll-sass-converter"

Jekyll.logger.log_level = :error
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "random"

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
    Jekyll.configuration(overrides.merge(
                           "source"      => source_dir,
                           "destination" => dest_dir
                         ))
  end

  def scss_converter_instance(site)
    if Jekyll::VERSION >= "3.0"
      site.find_converter_instance(Jekyll::Converters::Scss)
    else
      site.getConverterImpl(Jekyll::Converters::Scss)
    end
  end
end
