# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

describe(Jekyll::Converters::Scss) do
  let(:site) do
    Jekyll::Site.new(site_configuration)
  end

  let(:scss_converter) do
    scss_converter_instance(site)
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

  let(:expanded_css_output) do
    <<~CSS.chomp
      body {
        font-family: Helvetica, sans-serif;
        font-color: fuschia;
      }
    CSS
  end

  let(:invalid_content) do
    <<~SCSS
      $font-stack: Helvetica
      body {
        font-family: $font-stack;
    SCSS
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
    it "set the load paths to the _sass dir relative to site source" do
      expect(converter.sass_configs[:load_paths]).to eql([source_dir("_sass")])
    end

    it "allow for other styles" do
      expect(converter("style" => :compressed).sass_configs[:style]).to eql(:compressed)
    end

    context "when specifying sass dirs" do
      context "when the sass dir exists" do
        it "allow the user to specify a different sass dir" do
          create_directory(source_dir("_scss"))
          override = { "sass_dir" => "_scss" }
          expect(converter(override).sass_configs[:load_paths]).to eql([source_dir("_scss")])
          remove_directory(source_dir("_scss"))
        end

        it "not allow sass_dirs outside of site source" do
          expect(
            converter("sass_dir" => "/etc/passwd").sass_dir_relative_to_site_source
          ).to eql("etc/passwd")
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

      it "defaults style to :expanded for sass-embedded" do
        expect(verter.sass_configs[:style]).to eql(:expanded)
      end

      it "at least contains :syntax and :load_paths keys" do
        expect(verter.sass_configs.keys).to include(:load_paths, :syntax)
      end
    end
  end

  context "converting SCSS" do
    it "produces CSS" do
      expect(converter.convert(content)).to eql(expanded_css_output)
    end

    it "includes the syntax error line in the syntax error message" do
      expected = %r!expected ";"!i
      expect { scss_converter.convert(invalid_content) }.to(
        raise_error(Jekyll::Converters::Scss::SyntaxError, expected)
      )
    end

    it "does not include the charset without an associated page" do
      overrides = { "style" => :expanded }
      result = converter(overrides).convert(%(a{content:"あ"}))
      expect(result).to eql(%(a {\n  content: "あ";\n}))
    end

    it "does not include the BOM without an associated page" do
      overrides = { "style" => :compressed }
      result = converter(overrides).convert(%(a{content:"あ"}))
      expect(result).to eql(%(a{content:"あ"}))
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
        ".half{width:50%}\n/*# sourceMappingURL=main.css.map */"
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
    let(:test_css_file) { dest_dir("css", "main.css") }

    context "in unsafe mode" do
      let(:site) do
        make_site(
          "source" => sass_lib,
          "sass"   => {
            "load_paths" => external_library,
          }
        )
      end

      before(:each) { create_directory external_library }
      after(:each)  { remove_directory external_library }

      it "recognizes the new load path" do
        expect(scss_converter.sass_load_paths).to include(external_library)
      end

      it "ensures the sass_dir is still in the load path" do
        expect(scss_converter.sass_load_paths).to include(sass_lib("_sass"))
      end

      it "brings in the grid partial" do
        site.process

        expected = "a {\n  color: #999999;\n}\n/*# sourceMappingURL=main.css.map */"
        expect(File.read(test_css_file)).to eql(expected)
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
          expect(scss_converter.sass_load_paths).to eql([external_library, sass_lib("_sass")])
        end
      end
    end

    context "in safe mode" do
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
        expect(scss_converter.sass_load_paths).not_to include(external_library)
      end

      it "ensures the sass_dir is the entire load path" do
        expect(scss_converter.sass_load_paths).to eql([sass_lib("_sass")])
      end
    end
  end

  context "importing from internal libraries" do
    let(:internal_library) { source_dir("bower_components/jquery") }

    before(:each) { create_directory internal_library }
    after(:each)  { remove_directory internal_library }

    context "in unsafe mode" do
      let(:site) do
        make_site(
          "sass" => {
            "load_paths" => ["bower_components/*"],
          }
        )
      end

      it "expands globs" do
        expect(scss_converter.sass_load_paths).to include(internal_library)
      end
    end

    context "in safe mode" do
      let(:site) do
        make_site(
          "safe" => true,
          "sass" => {
            "load_paths" => [
              Dir.tmpdir,
              "bower_components/*",
              "../..",
            ],
          }
        )
      end

      it "allows local load paths" do
        expect(scss_converter.sass_load_paths).to include(internal_library)
      end

      it "ignores external load paths" do
        expect(scss_converter.sass_load_paths).not_to include(Dir.tmpdir)
      end

      it "does not allow traversing outside source directory" do
        scss_converter.sass_load_paths.each do |path|
          expect(path).to include(source_dir)
          expect(path).not_to include("..")
        end
      end
    end
  end

  context "with valid sass paths in a theme" do
    context "in unsafe mode" do
      let(:site) do
        make_site("theme" => "minima")
      end

      it "includes the theme's sass directory" do
        expect(site.theme.sass_path).to be_truthy
        expect(scss_converter.sass_load_paths).to include(site.theme.sass_path)
      end
    end

    context "in safe mode" do
      let(:site) do
        make_site(
          "theme" => "minima",
          "safe"  => true
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
          "style" => :expanded,
        },
        "collections" => {
          "pages" => {
            "output" => true,
          },
        }
      )
    end

    it "produces CSS without raising errors" do
      expect { site.process }.not_to raise_error
      expect(scss_converter.convert(content)).to eql(expanded_css_output)
    end
  end

  context "in a site nested inside directory with square brackets" do
    let(:site) do
      make_site(
        "source" => File.expand_path("[alpha]beta", __dir__),
        "sass"   => {
          "style" => :expanded,
        }
      )
    end

    it "produces CSS without raising errors" do
      expect { site.process }.not_to raise_error
      expect(scss_converter.convert(content)).to eql(expanded_css_output)
    end
  end

  context "generating sourcemap" do
    let(:sourcemap_file) { dest_dir("css/app.css.map") }
    let(:sourcemap_contents) { File.binread(sourcemap_file) }
    before { site.process }

    it "outputs the sourcemap file" do
      expect(File.exist?(sourcemap_file)).to be true
    end

    it "should not have Liquid expressions rendered" do
      expect(sourcemap_contents).to include("{{ site.mytheme.skin }}")
    end

    context "in a site with source not equal to its default value of `Dir.pwd`" do
      let(:site) do
        make_site(
          "source" => File.expand_path("nested_source/src", __dir__)
        )
      end
      let(:sourcemap_file) { dest_dir("css/main.css.map") }
      let(:sourcemap_data) { JSON.parse(File.binread(sourcemap_file)) }

      before(:each) { site.process }

      it "outputs the sourcemap file" do
        expect(File.exist?(sourcemap_file)).to be_truthy
      end

      it "contains relevant sass sources" do
        sources = sourcemap_data["sources"]
        # paths are relative to input file
        expect(sources).to include("../_sass/_grid.scss")
        expect(sources).to_not include("../_sass/_color.scss") # not imported into "main.scss"
      end

      it "does not leak directory structure outside of `site.source`" do
        site_source_relative_from_pwd = \
          Pathname.new(site.source)
            .relative_path_from(Pathname.new(Dir.pwd))
            .to_s
        relative_path_parts = site_source_relative_from_pwd.split(File::SEPARATOR)

        expect(site_source_relative_from_pwd).to eql("spec/nested_source/src")
        expect(relative_path_parts).to eql(%w(spec nested_source src))

        relative_path_parts.each do |dirname|
          sourcemap_data["sources"].each do |fpath|
            expect(fpath).to_not include(dirname)
          end
        end
      end
    end
  end
end
