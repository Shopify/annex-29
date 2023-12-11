Gem::Specification.new do |spec|
  spec.name = "annex_29"
  spec.version = "0.1.1"
  spec.date = "2016-10-18"
  spec.summary = "Unicode annex 29 compliant word segmentation"
  spec.authors = ["Simon Génier"]
  spec.email = "simon.genier@shopify.com"
  spec.files = %w(
    lib/annex_29.rb
    lib/annex_29/word_segmentation.rb
  )
  spec.homepage = "https://github.com/Shopify/annex-29"
  spec.license = "Apache-2.0"

  spec.add_development_dependency("rake", "~> 12.3")
  spec.add_development_dependency("rspec", "~> 3.5")
end
