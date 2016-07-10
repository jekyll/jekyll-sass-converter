# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll-sass-converter/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-sass-converter"
  spec.version       = JekyllSassConverter::VERSION
  spec.authors       = ["Parker Moore"]
  spec.email         = ["parkrmoore@gmail.com"]
  spec.summary       = %q{A basic Sass converter for Jekyll.}
  spec.homepage      = "https://github.com/jekyll/jekyll-sass-converter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r{^lib/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sass", "~> 3.4"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "jekyll", ENV["JEKYLL_VERSION"] ? "~> #{ENV["JEKYLL_VERSION"]}" : "~> 3.0"
end
