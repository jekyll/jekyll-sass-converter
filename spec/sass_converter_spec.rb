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

  let(:expanded_css_output) do
    <<~CSS
      body {
        font-family: Helvetica, sans-serif;
        font-color: fuschia;
      }
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
      expect(converter.convert(content)).to eql(expanded_css_output)
    end

    it "includes the syntax error line in the syntax error message" do
      expected = %r!Expected newline!i
      expect do
        converter.convert(invalid_content)
      end.to raise_error(Jekyll::Converters::Scss::SyntaxError, expected)
    end

    it "does not include the charset without an associated page" do
      overrides = { "style" => :expanded }
      result = converter(overrides).convert(%(a\n  content: "あ"))
      expect(result).to eql(%(a {\n  content: "あ";\n}\n))
    end

    it "does not include the BOM without an associated page" do
      overrides = { "style" => :compressed }
      result = converter(overrides).convert(%(a\n  content: "あ"))
      expect(result).to eql(%(a{content:"あ"}\n))
      expect(result.bytes.to_a[0..2]).not_to eql([0xEF, 0xBB, 0xBF])
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
      expect(sass_converter.convert(content)).to eql(expanded_css_output)
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
      expect(sass_converter.convert(content)).to eql(expanded_css_output)
    end
  end
end
