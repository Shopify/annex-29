RSpec.describe(Annex29.method(:segment_words)) do
  class << self
    def parse_sample(sample)
      sample = sample.sub(/^\s*÷/, "").sub(/÷\s*$/, "")
      source = sample.split(/[÷×]/).map do |code_point|
        code_point.strip.hex
      end.pack("U*")
      expected = sample.split("÷").map do |fragment|
        fragment.split("×").map do |code_point|
          code_point.strip.hex
        end.pack("U*")
      end
      [source, expected]
    end

    def each_samples
      tests = Set.new
      file_name = Pathname.new("data").join("WordBreakTest.txt")
      File.open(file_name).each_line do |line|
        next unless match = line.match(/^(?<sample>[^#]+)#(?<description>.*)/)
        sample, expected = parse_sample(match["sample"])
        description = match["description"].strip
        next if tests.include?(sample)
        tests.add(sample)
        yield sample, expected, description
      end
    end
  end

  each_samples do |sample, expected, description|
    it "segments #{description}" do
      expect(
        Annex29.segment_words(sample),
      ).to eq(expected)
    end
  end
end
