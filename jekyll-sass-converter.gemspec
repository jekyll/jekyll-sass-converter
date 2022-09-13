# frozen_string_literal: true

require_relative "lib/jekyll-sass-converter/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-sass-converter"
  spec.version       = JekyllSassConverter::VERSION
  spec.authors       = ["Parker Moore"]
  spec.email         = ["parkrmoore@gmail.com"]
  spec.summary       = "A basic Sass converter for Jekyll."
  spec.homepage      = "https://github.com/jekyll/jekyll-sass-converter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r!^lib/!)
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6.0"

  spec.add_runtime_dependency "sass-embedded", "~> 1.54"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop-jekyll", "~> 0.12.0"
end
