# Jekyll Sass Converter

Let Jekyll build your Sass and SCSS!

[![Build Status](https://travis-ci.org/jekyll/jekyll-sass-converter.svg?branch=master)](https://travis-ci.org/jekyll/jekyll-sass-converter)
[![Windows Build status](https://img.shields.io/appveyor/ci/jekyll/jekyll-sass-converter/master.svg?label=Windows%20build)](https://ci.appveyor.com/project/jekyll/jekyll-sass-converter/branch/master)


## Installation

**Jekyll Sass Converter requires Jekyll 2.0.0 or greater and is bundled
with Jekyll so you don't need to install it if you're already using Jekyll.**

Add this line to your application's Gemfile:

    gem 'jekyll-sass-converter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-sass-converter

## Usage

Jekyll Sass Converter comes bundled with Jekyll 2.0.0 and greater. For more
information about usage, visit the [Jekyll Assets Documentation
page](http://jekyllrb.com/docs/assets/).

### Source Maps

Starting with `v2.0`, the Converter will by default generate a _source map_ file along with
the `.css` output file. The _source map_ is useful when we use the web developers tools of
[Chrome](https://developers.google.com/web/tools/chrome-devtools/) or
[Firefox](https://developer.mozilla.org/en-US/docs/Tools) to debug our `.sass` or `.scss`
stylesheets.

The _source map_ is a file that maps from the output `.css` file to the original source
`.sass` or `.scss` style sheets. Thus enabling the browser to reconstruct the original source
and present the reconstructed original in the debugger.

Source map generation cannot be disabled as of now. However, there is one configuration option
associated with source maps and this converter:

  * **`line_comments`**

    When set to _true_, the line number and filename of the source is included in the compiled
    CSS-file. Useful for debugging when the _source-map_ is not available, but might
    considerably increase the size of the generated CSS files.

    Defaults to `false`.

## Contributing

1. Fork it ( http://github.com/jekyll/jekyll-sass-converter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
