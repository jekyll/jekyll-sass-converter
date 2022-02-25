# Jekyll Sass Converter

Let Jekyll build your Sass and SCSS!

[![Continuous Integration](https://github.com/jekyll/jekyll-sass-converter/actions/workflows/ci.yml/badge.svg)](https://github.com/jekyll/jekyll-sass-converter/actions/workflows/ci.yml)


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
page](https://jekyllrb.com/docs/assets/).

### Sass Implementations

#### SassC

By default, Jekyll Sass Converter uses [sassc](https://rubygems.org/gems/sassc)
for Sass implmentation. `sassc` is based on LibSass, and
[LibSass is deprecated](https://sass-lang.com/blog/libsass-is-deprecated).

#### Sass Embedded

[sass-embedded](https://rubygems.org/gems/sass-embedded) is a host for the
[Sass embedded protocol](https://github.com/sass/embedded-protocol).

The host runs [Dart Sass compiler](https://github.com/sass/dart-sass-embedded) as a subprocess
and communicates with the dart-sass compiler by sending / receiving
[protobuf](https://github.com/protocolbuffers/protobuf) messages via the standard
input-output channel.

To use the `sass-embedded` implementation, you need to first install the `sass-embedded` gem
either via your `Gemfile` and Bundler, or directly. Then, you have to specify `sass-embedded`
as the desired implementation in your `_config.yml`:

```yaml
sass:
  implementation: sass-embedded
```

### Source Maps

Starting with `v2.0`, the Converter will by default generate a _source map_ file along with
the `.css` output file. The _source map_ is useful when we use the web developers tools of
[Chrome](https://developers.google.com/web/tools/chrome-devtools/) or
[Firefox](https://developer.mozilla.org/en-US/docs/Tools) to debug our `.sass` or `.scss`
stylesheets.

The _source map_ is a file that maps from the output `.css` file to the original source
`.sass` or `.scss` style sheets. Thus enabling the browser to reconstruct the original source
and present the reconstructed original in the debugger.

### Configuration Options

Configuration options are specified in the `_config.yml` file in the following way:

  ```yml
  sass:
    <option_name1>: <option_value1>
    <option_name2>: <option_value2>
  ```

Available options are:

  * **`implementation`**

    Sets the Sass implementation to use.
    Can be `sassc` or `sass-embedded`.

    Defaults to `sassc`.

  * **`style`**

    Sets the style of the CSS-output.
    Can be `nested`, `compact`, `compressed`, or `expanded`.
    See the [SASS_REFERENCE](https://sass-lang.com/documentation/cli/dart-sass#style)
    for details.

    Defaults to `compact` for `sassc`.
    Defaults to `expanded` for `sass-embedded`.

  * **`sass_dir`**

    A filesystem-path which should be searched for Sass partials.

    Defaults to `_sass`

  * **`load_paths`**

    An array of additional filesystem-paths which should be searched for Sass partials.

    Defaults to `[]`

  * **`line_comments`**

    When set to _true_, the line number and filename of the source is included in the compiled
    CSS-file. Useful for debugging when the _source map_ is not available, but might
    considerably increase the size of the generated CSS files.

    Defaults to `false`.

  * **`sourcemap`**

    Controls when source maps shall be generated.

    - `never` &mdash; causes no source maps to be generated at all.
    - `always` &mdash; source maps will always be generated.
    - `development` &mdash; source maps will only be generated if the site is in development
      [environment](https://jekyllrb.com/docs/configuration/environments/).
      That is, when the environment variable `JEKYLL_ENV` is set to `development`.

    Defaults to `always`.


## Contributing

1. Fork it ( https://github.com/jekyll/jekyll-sass-converter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
