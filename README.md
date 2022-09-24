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

Starting with `v3.0`, Jekyll Sass Converter uses `sass-embedded` for Sass implmentation.

Please see [migrate from 2.x to 3.x](#migrate-from-2x-to-3x) for more information.

#### Sass Embedded

[sass-embedded](https://rubygems.org/gems/sass-embedded) is a host for the
[Sass embedded protocol](https://github.com/sass/embedded-protocol).

The host runs [Dart Sass compiler](https://github.com/sass/dart-sass-embedded) as a subprocess
and communicates with the dart-sass compiler by sending / receiving
[protobuf](https://github.com/protocolbuffers/protobuf) messages via the standard
input-output channel.

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

  * **`style`**

    Sets the style of the CSS-output.
    Can be `compressed` or `expanded`.
    See the [SASS_REFERENCE](https://sass-lang.com/documentation/cli/dart-sass#style)
    for details.

    Defaults to `expanded`.

  * **`sass_dir`**

    A filesystem-path which should be searched for Sass partials.

    Defaults to `_sass`

  * **`load_paths`**

    An array of additional filesystem-paths which should be searched for Sass partials.

    Defaults to `[]`

  * **`sourcemap`**

    Controls when source maps shall be generated.

    - `never` &mdash; causes no source maps to be generated at all.
    - `always` &mdash; source maps will always be generated.
    - `development` &mdash; source maps will only be generated if the site is in development
      [environment](https://jekyllrb.com/docs/configuration/environments/).
      That is, when the environment variable `JEKYLL_ENV` is set to `development`.

    Defaults to `always`.

  * **`quiet_deps`**

    If this option is set to `true`, Sass won’t print warnings that are caused by dependencies.
    A “dependency” is defined as any file that’s loaded through `sass_dir` or `load_paths`.
    Stylesheets that are imported relative to the entrypoint are not considered dependencies.

    Defaults to `false`.

  * **`verbose`**

    By default, Dart Sass will print only five instances of the same deprecation warning per
    compilation to avoid deluging users in console noise. If you set `verbose` to `true`, it will
    instead print every deprecation warning it encounters.

    Defaults to `false`.

## Migrate from 2.x to 3.x

Classic GitHub Pages experience still uses [1.x version of jekyll-sass-converter](https://pages.github.com/versions/).

To use latest Jekyll and Jekyll Sass Converter on GitHub Pages,
[you can now deploy to a GitHub Pages site using GitHub Actions](https://github.blog/changelog/2022-07-27-github-pages-custom-github-actions-workflows-beta/).

### Dropped `implmentation` Option

In `v3.0.0`, `sass-embedded` gem becomes the default Sass implmentation, and `sassc` gem
is no longer supported. As part of this change, support for Ruby 2.5 is dropped.

### Dropped `add_charset` Option

The Converter will no longer emit `@charset "UTF-8";` or a U+FEFF (byte-order marker) for
`sassify` and `scssify` Jekyll filters so that this option is no longer needed.

### Dropped `line_comments` Option

`sass-embedded` does not support `line_comments` option.

### Dropped support of importing files with non-standard extension names

`sass-embedded` only allows importing files that have extension names of `.sass`, `.scss`
or `.css`. Scss syntax in files with `.css` extension name will result in a syntax error.

### Dropped support of importing files relative to site source

In `v2.x`, the Converter allowed imports using paths relative to site source directory,
even if the site source directory is not in Sass `load_paths`. This is a side effect of a
bug in the Converter, which will remain as is in `v2.x` due to its usage in the wild.

In `v3.x`, imports using paths relative to site source directory will not work out of box.
To allow these imports, `.` (meaning current directory, or site source directory) need to
be explicitly added to `load_paths` option.

### Dropped support of importing files with the same filename as their parent file

In `v2.x`, the Converter allowed imports of files with the same filename as their parent
file from `sass_dir` or `load_paths`. This is a side effect of a bug in the Converter,
which will remain as is in `v2.x` due to its usage in the wild.

In `v3.x`, imports using the same filename of parent file will create a circular import.
To fix these imports, rename either of the files, or use complete relative path from the
parent file.

### Behavioral Differences in Sass Implementation

Please see https://github.com/sass/dart-sass#behavioral-differences-from-ruby-sass.

## Contributing

1. Fork it ( https://github.com/jekyll/jekyll-sass-converter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
