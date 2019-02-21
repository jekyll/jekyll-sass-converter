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

Starting with this version, the Converter will by default generate a _source map_ file
along with the `.css` output file. The _source map_ is useful when we use the
web developers tools of 
[Chrome](https://developers.google.com/web/tools/chrome-devtools/)
or 
[Firefox](https://developer.mozilla.org/en-US/docs/Tools) 
to debug our `.sass` or `.scss` style sheets.
The _source map_ is a file that maps from the output `.css` file to the 
original source `.sass` or `.scss` style sheets.
Thus enabling the browser to reconstruct the original source 
and present the reconstructed original in the debugger.

Here is some additional information to the above mentioned _Jekyll Assets Documentation page_:

1. ...For instance, if you have a file named `css/styles.scss` in 
   your site’s source folder, Jekyll will process it and put it 
   in your site’s destination folder under `css/styles.css` __and `css/styles.css.map`__.

2. ...Jekyll allows you to customize your Sass conversion in certain ways...  

   There are a number of options which are communicated to the underlying `sassc` library. 
   You can specify these in your `_config.yml` file in the following way:
   ```yml
   sass:
       <option_name1>: <option_value1>
       <option_name2>: <option_value2>
   ```

   Available options are:
   
   * **`style`**
     Sets the style of the CSS-output.
     Can be `nested`, `compact`, `compressed`, or `expanded`.
     See the [SASS_REFERENCE](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#output_style)
     for details.  
     
     Defaults to `compact`.
     
   * **`sass_dir`**
     An array of filesystem-paths which should be searched for Sass-partials.
     
     Defaults to `_sass`.     
     
   * **`precision`**
     Sets the precision factor used in numeric output.
   
   * **`source_map_contents`**
     When set to _true_ the full source text will be included in the _source-map_.
     Useful for debugging in situations where the server cannot access the original source files
     (which is usually the case for Jekyll sites).
     
     Defaults to `true`.        
         
   * **`line_comments`**
     When set to _true_ causes the line number and filename of the source be emitted into the compiled CSS-file. 
     Useful for debugging when the _source-map_ is not available. 

## Contributing

1. Fork it ( http://github.com/jekyll/jekyll-sass-converter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
