# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "annex_29/version"

Gem::Specification.new do |spec|
  spec.name = "annex_29"
  spec.version = Annex29::VERSION
  spec.summary = "Unicode annex 29 compliant word segmentation"
  spec.author = "Shopify"
  spec.email = "developers@shopify.com"
  spec.homepage = "https://github.com/Shopify/annex-29"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.files = %x(git ls-files -z).split("\x0").reject do |f|
    f.match(%r{^(rake|test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.2.0"


  spec.add_development_dependency("rake", "~> 11.3")
  spec.add_development_dependency("rspec", "~> 3.5")
end
