# frozen_string_literal: true

require "spec_helper"

describe(Jekyll::Converters::Sass) do
  let(:site) do
    Jekyll::Site.new(site_configuration)
  end

  let(:sass_converter) do
    sass_converter_instance(site)
  end

  let(:content) do
    <<~SASS
      // tl;dr some sass
      $font-stack: Helvetica, sans-serif
      body
        font-family: $font-stack
        font-color: fuschia
    SASS
  end

  let(:css_output) do
    <<~CSS
      body { font-family: Helvetica, sans-serif; font-color: fuschia; }
    CSS
  end

  let(:invalid_content) do
    <<~SASS
      font-family: $font-stack;
    SASS
  end

  def converter(overrides = {})
    sass_converter_instance(site).dup.tap do |obj|
      obj.instance_variable_get(:@config)["sass"] = overrides
    end
  end

  context "matching file extensions" do
    it "does not match .scss files" do
      expect(converter.matches(".scss")).to be_falsey
    end

    it "matches .sass files" do
      expect(converter.matches(".sass")).to be_truthy
    end
  end

  context "converting sass" do
    it "produces CSS" do
      expect(converter.convert(content)).to eql(css_output)
    end

    it "includes the syntax error line in the syntax error message" do
      error_message = 'Error: Invalid CSS after "f": expected 1 selector or at-rule.'
      error_message = %r!\A#{error_message} was "font-family: \$font-"\s+on line 1:1 of stdin!
      expect do
        converter.convert(invalid_content)
      end.to raise_error(Jekyll::Converters::Scss::SyntaxError, error_message)
    end

    it "removes byte order mark from compressed Sass" do
      result = converter("style" => :compressed).convert(%(a\n  content: "\uF015"))
      expect(result).to eql(%(a{content:"\uF015"}\n))
      expect(result.bytes.to_a[0..2]).not_to eql([0xEF, 0xBB, 0xBF])
    end

    it "does not include the charset unless asked to" do
      overrides = { "style" => :compressed, "add_charset" => true }
      result = converter(overrides).convert(%(a\n  content: "\uF015"))
      expect(result).to eql(%(@charset "UTF-8";a{content:"\uF015"}\n))
      expect(result.bytes.to_a[0..2]).not_to eql([0xEF, 0xBB, 0xBF])
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

    it "produces CSS without raising errors" do
      expect { site.process }.not_to raise_error
      expect(sass_converter.convert(content)).to eql(css_output)
    end
  end

  context "in a site nested inside directory with square brackets" do
    let(:site) do
      make_site(
        "source" => File.expand_path("[alpha]beta", __dir__),
        "sass"   => {
          "style" => :compact,
        }
      )
    end

    it "produces CSS without raising errors" do
      expect { site.process }.not_to raise_error
      expect(sass_converter.convert(content)).to eql(css_output)
    end
  end
end
