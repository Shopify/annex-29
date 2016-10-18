module Annex29
  require("annex_29/word_segmentation")

  class << self
    def segment_words(input)
      Annex29::WordSegmentation.call(String(input))
    end
  end
end
