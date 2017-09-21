require 'spec_helper'

describe(Jekyll::Converters::Sass) do
  let(:site) do
    Jekyll::Site.new(site_configuration)
  end
  let(:content) do
    <<-SASS
// tl;dr some sass
$font-stack: Helvetica, sans-serif
body
  font-family: $font-stack
  font-color: fuschia
SASS
  end
  let(:css_output) do
    <<-CSS
body {\n  font-family: Helvetica, sans-serif;\n  font-color: fuschia; }
CSS
  end
  let(:invalid_content) do
    <<-SASS
font-family: $font-stack;
SASS
  end

  def compressed(content)
    content.gsub(/\s+/, '').gsub(/;}/, '}') + "\n"
  end

  def converter(overrides = {})
    Jekyll::Converters::Sass.new(site_configuration({"sass" => overrides}))
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
      expect(converter.convert(content)).to eql(compressed(css_output))
    end

    it "includes the syntax error line in the syntax error message" do
      error_message = "Invalid CSS after \"$font-stack\": expected expression (e.g. 1px, bold), was \";\" on line 1"
      expect {
        converter.convert(invalid_content)
      }.to raise_error(Jekyll::Converters::Scss::SyntaxError, error_message)
    end

    it "removes byte order mark from compressed Sass" do
      result = converter({ "style" => :compressed }).convert("a\n  content: \"\uF015\"")
      expect(result).to eql("a{content:\"\uF015\"}\n")
      expect(result.bytes.to_a[0..2]).not_to eql([0xEF, 0xBB, 0xBF])
    end

    it "does not include the charset if asked not to" do
      result = converter({ "style" => :compressed, "add_charset" => true }).convert("a\n  content: \"\uF015\"")
      expect(result).to eql("@charset \"UTF-8\";a{content:\"\uF015\"}\n")
      expect(result.bytes.to_a[0..2]).not_to eql([0xEF, 0xBB, 0xBF])
    end

    it "does not include source line-number comments unless asked to debug uncompressed CSS" do
      debug_uncompressed = converter({ "style" => :nested, "debug" => true }).convert(content)
      debug_compressed = converter({ "style" => :compressed, "debug" => true }).convert(content)
      expect(debug_uncompressed).to eql("/* line 3 */\n#{css_output}")
      expect(debug_compressed).to eql(compressed(css_output))
    end
  end
end
