# frozen_string_literal: true

source "https://rubygems.org"
gemspec

gem "jekyll", ENV["JEKYLL_VERSION"] ? "~> #{ENV["JEKYLL_VERSION"]}" : ">= 4.0"
gem "minima"

gem "sass-embedded", "~> 0.8.0" if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.6.0")
