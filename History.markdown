## HEAD

### Documentation

  * Update README with requirements for sass-embedded (#150)
  * Fix &#34;implementation&#34; typos (#151)
  * Update dart-sass repo link in README.md (#154)

### Development Fixes

  * Update sass embedded protocol documentation link (#157)
  * Bump `actions/checkout` to v4 (#165)

### Minor Enhancements

  * Display sass error in browser with livereload (#160)

## 3.0.0 / 2022-12-21

### Major Enhancements

  * Drop support for sassc (#140)
  * Add quiet_deps and verbose option (#143)
  * Remove extra newline in css output (#144)

## 2.2.0 / 2022-02-28

### Minor Enhancements

  * Support sass-embedded as alternative implementation (#124)

### Bug Fixes

  * Source map sources should to be relative to site.source (#119)
  * Sourcemaps should not be rendered by Liquid (#123)

### Development Fixes

  * Migrate from AppVeyor CI to GH Actions (#125)
  * Refactor specs to reduce repetition (#126)
  * Reduce overall class size (#132)
  * Use new sass-embedded api (#131)
  * Add workflow to release gem via GH Actions (#134)

### Documentation

  * Update CI status badge (#127)
  * Update `sass-embedded` info in `README.md` (#133)

## 2.1.0 / 2020-02-05

### Development Fixes

  * chore(ci): use Ubuntu 18.04 (bionic) (#100)

### Minor Enhancements

  * Fix `Scss#sass_dir_relative_to_site_source` logic (#99)

## 2.0.1 / 2019-09-26

### Bug Fixes

  * Do not register hooks for documents of type :pages (#94)
  * Append theme&#39;s sass path after all sanitizations (#96)

## 2.0.0 / 2019-08-14

### Major Enhancements

  * Migrate to sassc gem (#75)
  * Use and test sassc-2.1.0 pre-releases and beyond (#86)
  * Drop support for Ruby 2.3 (#90)

### Minor Enhancements

  * Generate Sass Sourcemaps (#79)
  * Configure Sass to load from theme-gem if possible (#80)
  * SyntaxError line and filename are set by SassC (#85)
  * Memoize #jekyll_sass_configuration (#82)

### Development Fixes

  * Target Ruby 2.3 (#70)
  * Lint with rubocop-jekyll (#73)
  * Clear out RuboCop TODO (#87)
  * Cache stateless regexes in class constants (#83)
  * Add appveyor.yml (#76)

### Bug Fixes

  * Fix rendering of sourcemap page (#89)

## 1.5.2 / 2017-02-03

### Development Fixes

  * Test against Ruby 2.5 (#68)

## 1.5.1 / 2017-12-02

### Minor

  * Security: Bump Rubocop to 0.51

### Development Fixes

  * Drop support for Jekyll 2.x and Ruby 2.0 (#62)
  * Inherit Jekyll&#39;s rubocop config for consistency (#61)
  * Define path with __dir__ (#60)
  * Fix script/release

## 1.5.0 / 2016-11-14

  * Allow `load_paths` in safe mode with sanitization (#50)
  * SCSS converter: expand @config["source"] to be "safer". (#55)
  * Match Ruby versions with jekyll/jekyll (#46)
  * Don't test Jekyll 2.5 against Ruby 2.3. (#52)

## 1.4.0 / 2015-12-25

### Minor Enhancements

  * Bump Sass to v3.4 and above. (#40)
  * Strip byte order mark from generated compressed Sass/SCSS (#39)
  * Strip BOM by default, but don't add in the `@charset` by default (#42)

### Development Fixes

  * Add Jekyll 2 & 3 to test matrix (#41)

## 1.3.0 / 2014-12-07

### Minor Enhancements

  * Include line number in syntax error message (#26)
  * Raise a `Jekyll::Converters::Scss::SyntaxError` instead of just a `StandardError` (#29)

### Development Fixes

  * Fix typo in SCSS converter spec filename (#27)
  * Add tests for custom syntax error handling (#29)

## 1.2.1 / 2014-08-30

  * Only include something in the sass load path if it exists (#23)

## 1.2.0 / 2014-07-31

### Minor Enhancements

  * Allow user to specify style in safe mode. (#16)

### Development Fixes

  * Only include the `lib/` files in the gem. (#17)

## 1.1.0 / 2014-07-29

### Minor Enhancements

  * Implement custom load paths (#14)
  * Lock down sass configuration when in safe mode. (#15)

## 1.0.0 / 2014-05-06

  * Birthday!
  * Don't use core extensions (#2)
  * Allow users to set style of outputted CSS (#4)
  * Determine input syntax based on file extension (#9)
