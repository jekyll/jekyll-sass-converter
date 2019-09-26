# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

describe(Jekyll::Converters::Scss) do
  let(:site) do
    Jekyll::Site.new(site_configuration)
  end
  let(:content) do
    <<~SCSS
      $font-stack: Helvetica, sans-serif;
      body {
        font-family: $font-stack;
        font-color: fuschia;
      }
    SCSS
  end
  let(:css_output) do
    <<~CSS
      body { font-family: Helvetica, sans-serif; font-color: fuschia; }
    CSS
  end
  let(:invalid_content) do
    <<~SCSS
      $font-stack: Helvetica
      body {
        font-family: $font-stack;
    SCSS
  end

  def compressed(content)
    content.gsub(%r!\s+!, "").gsub(%r!;}!, "}") + "\n"
  end

  def converter(overrides = {})
    scss_converter_instance(site).dup.tap do |obj|
      obj.instance_variable_get(:@config)["sass"] = overrides
    end
  end

  context "matching file extensions" do
    it "matches .scss files" do
      expect(converter.matches(".scss")).to be_truthy
    end

    it "does not match .sass files" do
      expect(converter.matches(".sass")).to be_falsey
    end
  end

  context "determining the output file extension" do
    it "always outputs the .css file extension" do
      expect(converter.output_ext(".always-css")).to eql(".css")
    end
  end

  context "when building configurations" do
    # Caching is no more a feature with sassC
    # it "allow caching in unsafe mode" do
    #   expect(converter.sass_configs[:cache]).to be_truthy
    # end

    it "set the load paths to the _sass dir relative to site source" do
      expect(converter.sass_configs[:load_paths]).to eql([source_dir("_sass")])
    end

    it "allow for other styles" do
      expect(converter("style" => :compressed).sass_configs[:style]).to eql(:compressed)
    end

    context "when specifying sass dirs" do
      context "when the sass dir exists" do
        it "allow the user to specify a different sass dir" do
          FileUtils.mkdir(source_dir("_scss"))
          override = { "sass_dir" => "_scss" }
          expect(converter(override).sass_configs[:load_paths]).to eql([source_dir("_scss")])
          FileUtils.rmdir(source_dir("_scss"))
        end

        it "not allow sass_dirs outside of site source" do
          expect(
            converter("sass_dir" => "/etc/passwd").sass_dir_relative_to_site_source
          ).to eql(source_dir("etc/passwd"))
        end
      end
    end

    context "in safe mode" do
      let(:verter) do
        Jekyll::Converters::Scss.new(
          site.config.merge(
            "sass" => {},
            "safe" => true
          )
        )
      end

      it "does not allow caching" do
        expect(verter.sass_configs[:cache]).to be_falsey
      end

      it "forces load_paths to be just the local load path" do
        expect(verter.sass_configs[:load_paths]).to eql([source_dir("_sass")])
      end

      it "allows the user to specify the style" do
        allow(verter).to receive(:sass_style).and_return(:compressed)
        expect(verter.sass_configs[:style]).to eql(:compressed)
      end

      it "defaults style to :compact" do
        expect(verter.sass_configs[:style]).to eql(:compact)
      end

      it "at least contains :syntax and :load_paths keys" do
        expect(verter.sass_configs.keys).to include(:load_paths, :syntax)
      end
    end
  end

  context "converting SCSS" do
    it "produces CSS" do
      expect(converter.convert(content)).to eql(css_output)
    end

    it "includes the syntax error line in the syntax error message" do
      error_message = 'Error: Invalid CSS after "body": expected 1 selector or at-rule, was "{"'
      error_message = %r!\A#{error_message}\s+on line 2!
      expect do
        converter.convert(invalid_content)
      end.to raise_error(Jekyll::Converters::Scss::SyntaxError, error_message)
    end

    it "removes byte order mark from compressed SCSS" do
      result = converter("style" => :compressed).convert("a{content:\"\uF015\"}")
      expect(result).to eql(%(a{content:"\uF015"}\n))
      expect(result.bytes.to_a[0..2]).not_to eql([0xEF, 0xBB, 0xBF])
    end

    it "does not include the charset unless asked to" do
      overrides = { "style" => :compressed, "add_charset" => true }
      result = converter(overrides).convert(%(a{content:"\uF015"}))
      expect(result).to eql(%(@charset "UTF-8";a{content:"\uF015"}\n))
      expect(result.bytes.to_a[0..2]).not_to eql([0xEF, 0xBB, 0xBF])
    end
  end

  context "importing partials" do
    let(:test_css_file) { dest_dir("css/main.css") }
    before(:each) { site.process }

    it "outputs the CSS file" do
      expect(File.exist?(test_css_file)).to be_truthy
    end

    it "imports SCSS partial" do
      expect(File.read(test_css_file)).to eql(
        ".half{width:50%}\n\n/*# sourceMappingURL=main.css.map */"
      )
    end

    it "uses a compressed style" do
      instance = scss_converter_instance(site)
      expect(instance.jekyll_sass_configuration).to eql("style" => :compressed)
      expect(instance.sass_configs[:style]).to eql(:compressed)
    end
  end

  context "importing from external libraries" do
    let(:external_library) { source_dir("bower_components/jquery") }
    let(:verter) { scss_converter_instance(site) }
    let(:test_css_file) { dest_dir("css", "main.css") }

    context "unsafe mode" do
      let(:site) do
        make_site(
          "source" => sass_lib,
          "sass"   => {
            "load_paths" => external_library,
          }
        )
      end
      before(:each) do
        FileUtils.mkdir_p(external_library) unless File.directory?(external_library)
      end
      after(:each) do
        FileUtils.rmdir(external_library) if File.directory?(external_library)
      end

      it "recognizes the new load path" do
        expect(verter.sass_load_paths).to include(external_library)
      end

      it "ensures the sass_dir is still in the load path" do
        expect(verter.sass_load_paths).to include(sass_lib("_sass"))
      end

      it "brings in the grid partial" do
        site.process
        expect(File.read(test_css_file)).to eql(
          "a { color: #999999; }\n\n/*# sourceMappingURL=main.css.map */"
        )
      end

      context "with the sass_dir specified twice" do
        let(:site) do
          make_site(
            "source" => sass_lib,
            "sass"   => {
              "load_paths" => [
                external_library,
                sass_lib("_sass"),
              ],
            }
          )
        end

        it "ensures the sass_dir only occurrs once in the load path" do
          expect(verter.sass_load_paths).to eql([external_library, sass_lib("_sass")])
        end
      end
    end

    context "safe mode" do
      let(:site) do
        make_site(
          "safe"   => true,
          "source" => sass_lib,
          "sass"   => {
            "load_paths" => external_library,
          }
        )
      end

      it "ignores the new load path" do
        expect(verter.sass_load_paths).not_to include(external_library)
      end

      it "ensures the sass_dir is the entire load path" do
        expect(verter.sass_load_paths).to eql([sass_lib("_sass")])
      end
    end
  end

  context "importing from internal libraries" do
    let(:internal_library) { source_dir("bower_components/jquery") }
    let(:converter) { scss_converter_instance(site) }

    before(:each) do
      FileUtils.mkdir_p(internal_library) unless File.directory?(internal_library)
    end

    after(:each) do
      FileUtils.rmdir(internal_library) if File.directory?(internal_library)
    end

    context "unsafe mode" do
      let(:site) do
        make_site(
          "sass" => {
            "load_paths" => ["bower_components/*"],
          }
        )
      end

      it "expands globs" do
        expect(converter.sass_load_paths).to include(internal_library)
      end
    end

    context "safe mode" do
      let(:site) do
        Jekyll::Site.new(
          site_configuration.merge(
            "safe" => true,
            "sass" => {
              "load_paths" => [
                Dir.tmpdir,
                "bower_components/*",
                "../..",
              ],
            }
          )
        )
      end

      it "allows local load paths" do
        expect(converter.sass_load_paths).to include(internal_library)
      end

      it "ignores external load paths" do
        expect(converter.sass_load_paths).not_to include(Dir.tmpdir)
      end

      it "does not allow traversing outside source directory" do
        converter.sass_load_paths.each do |path|
          expect(path).to include(source_dir)
          expect(path).not_to include("..")
        end
      end
    end
  end

  context "with valid sass paths in a theme" do
    context "in unsafe mode" do
      let(:site) do
        Jekyll::Site.new(
          site_configuration.merge("theme" => "minima")
        )
      end

      it "includes the theme's sass directory" do
        expect(site.theme.sass_path).to be_truthy
        expect(converter.sass_load_paths).to include(site.theme.sass_path)
      end
    end

    context "in safe mode" do
      let(:site) do
        Jekyll::Site.new(
          site_configuration.merge(
            "theme" => "minima",
            "safe"  => true
          )
        )
      end

      it "includes the theme's sass directory" do
        expect(site.safe).to be true
        expect(site.theme.sass_path).to be_truthy
        expect(converter.sass_load_paths).to include(site.theme.sass_path)
      end
    end
  end

  context "in a site with a collection labelled 'pages'" do
    let(:site) do
      make_site(
        "source"      => File.expand_path("pages-collection", __dir__),
        "sass"        => {
          "style" => :compact,
        },
        "collections" => {
          "pages" => {
            "output" => true,
          },
        }
      )
    end

    let(:verter) { scss_converter_instance(site) }

    it "produces CSS without raising errors" do
      expect { site.process }.not_to raise_error
      expect(verter.convert(content)).to eql(css_output)
    end
  end
end
