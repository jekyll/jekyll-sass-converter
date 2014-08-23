---
layout: default
---

# This is an example site for Sass integration in Jekyll

You have two kinds of Sass files:

1. Main files, which you wish to be output as CSS files
2. Partials, which are used by main files in `@import` statements

Main files are like pages – they go where you want them to be output, and they contain the YAML front matter (`---` lines) at the top. Partials are like hidden Jekyll data, so they go in an underscored directory, which defaults to `_sass`. You site might look like this:

    .
    | - _sass
      | - _typography.scss
      | - _layout.scss
      | - _colors.scss
    | - stylesheets
      | - screen.scss
      | - print.scss

And so on.

The output, in your `_site` directory, would look like this:

    .
    | - stylesheets
      | - screen.css
      | - print.css

Boom! Now you have just your SCSS/Sass converted over to CSS with all the proper inputs.

# Specify Sass Directories in Jekyll

For this example, bower has installed bootstrap at `bower_components/bootstrap-sass-official/assets/stylesheets/bootstrap.scss`

In the Jekyll `_config.yml` file
```
sass:
  sass_dir: "_my_sass_dir" # this line only needed if you use something other than default "_sass"
  load_paths:  # add other load paths for sass files here
    - "bower_components"
    - "other_dir"
```

in your `main.scss` file:
```
@import "bootstrap-sass-official/assets/stylesheets/bootstrap.scss";
```

