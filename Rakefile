require("erb")
require("pathname")

UNICODE_DATA = Dir.glob("data/*.txt")

ANNEX_29_PATH = Pathname.new("lib/annex_29/")
WORD_SEGMENTATION_ERB = ANNEX_29_PATH.join("word_segmentation.rl.erb").to_s
WORD_SEGMENTATION_RL = ANNEX_29_PATH.join("word_segmentation.rl").to_s
WORD_SEGMENTATION_RB = ANNEX_29_PATH.join("word_segmentation.rb").to_s

file(WORD_SEGMENTATION_RL => [WORD_SEGMENTATION_ERB, *UNICODE_DATA]) do
  template = File.open(WORD_SEGMENTATION_ERB).read
  rendered = ERB.new(template).result
  File.open(
    WORD_SEGMENTATION_RL,
    File::CREAT | File::TRUNC | File::RDWR,
  ).write(rendered)
end

file(WORD_SEGMENTATION_RB => [WORD_SEGMENTATION_RL]) do
  sh("ragel", "-R", "-T1", "-o", WORD_SEGMENTATION_RB, WORD_SEGMENTATION_RL)
end

task(compile: [WORD_SEGMENTATION_RB])

task(default: [:compile])
