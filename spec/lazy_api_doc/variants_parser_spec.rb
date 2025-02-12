RSpec.describe LazyApiDoc::VariantsParser do
  let(:parser) { LazyApiDoc::VariantsParser.new(variants) }

  context "with simple types" do
    let(:variants) { [{ a: 1, b: "s", c: "1.1", d: true, e: nil }, { a: 2, b: "v", c: "2.3", d: false, e: nil }] }

    it "returns openapi structure" do
      expect(parser.result).to eq(
        "type" => "object",
        "properties" => {
          "a" => { "type" => "integer", "example" => 1 },
          "b" => { "type" => "string",  "example" => "s" },
          "c" => { "type" => "decimal", "example" => "1.1" },
          "d" => { "type" => "boolean", "example" => true },
          "e" => { "type" => "null",    "example" => nil }
        },
        "required" => %i[a b c d e]
      )
    end
  end

  context "with complex types" do
    let(:variants) { [{ a: [1, 2], h: {} }, { a: [3, 4], h: {} }] }

    it "returns openapi structure" do
      expect(parser.result).to eq(
        "type" => "object",
        "properties" => {
          "a" => {
            "type" => "array",
            "items" => { "type" => "integer", "example" => 1 },
            "example" => [1, 2]
          },
          "h" => {
            "type" => "object",
            "properties" => {},
            "required" => []
          }
        },
        "required" => %i[a h]
      )
    end
  end

  context "with mixed types" do
    let(:variants) { [{ a: 1 }, { a: "foo" }, {}] }

    it "returns openapi structure" do
      expect(parser.result).to eq(
        "type" => "object",
        "properties" => {
          "a" => {
            "oneOf" => [{ "type" => "integer" }, { "type" => "string" }],
            "example" => 1
          }
        },
        "required" => []
      )
    end
  end

  context "when the first hash doesn't have keys of the second hash" do
    let(:variants) { [{ a: 1 }, { b: 'foo' }] }

    it "returns keys for both hashes" do
      expect(parser.result).to eq(
        "type" => "object",
        "properties" => {
          "a" => {
            "type" => "integer",
            "example" => 1
          },
          "b" => {
            "type" => "string",
            "example" => "foo"
          }
        },
        "required" => []
      )
    end
  end

  context 'with optional array' do
    let(:variants) { [[1], nil] }

    it "returns" do
      expect(parser.result).to eq(
        "example" => [1],
        "items" => { "example" => 1, "type" => "integer" },
        "oneOf" => [{ "type" => "array" }, { "type" => "null" }]
      )
    end
  end

  context 'when mix of hash and array' do
    let(:variants) { [{'a' => 1}, []] }

    it "returns" do
      expect(parser.result).to eq(
                                 {
                                   "oneOf" => [
                                     {"type"=>"object"},
                                     {"type"=>"array"}
                                   ],
                                   "properties" => {
                                     "a" => {
                                       "example"=>1,
                                       "type"=>"integer"
                                     }
                                   },
                                   "required"=>["a"]
                                 }
                               )
    end
  end
end
