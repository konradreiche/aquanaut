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
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
