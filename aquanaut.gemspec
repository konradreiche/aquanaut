# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aquanaut/version'

Gem::Specification.new do |spec|
  spec.name          = "aquanaut"
  spec.version       = Aquanaut::VERSION
  spec.authors       = ["Konrad Reiche"]
  spec.email         = ["konrad.reiche@gmail.com"]
  spec.summary       = %q{Aquanaut creates a sitemap dynamically based on a given domain.}
  spec.description   = %q{Aquanaut creates a sitemap dynamically based on a given domain.}
  spec.homepage      = "https://github.com/platzhirsch/aquanaut"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 0.9"

  spec.add_dependency "public_suffix", "~> 1.4", ">= 1.4.0"
  spec.add_dependency "mechanize", "~> 2.7", ">= 2.7.3"
  spec.add_dependency "slim", "~> 2.0", ">= 2.0.1"
  spec.add_dependency "webmock", "~> 1.15", ">= 1.15.2"
end
