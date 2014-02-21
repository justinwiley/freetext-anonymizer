# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'freetext/anonymizer/version'

Gem::Specification.new do |spec|
  spec.name          = "freetext-anonymizer"
  spec.version       = Freetext::Anonymizer::VERSION
  spec.authors       = ["Justin Wiley"]
  spec.email         = ["justin.wiley@gmail.com"]
  spec.description   = %q{Quick and dirty freetext anonymizer}
  spec.summary       = %q{Quick and dirty freetext anonymizer}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "classifier"
  spec.add_runtime_dependency "tokenizer"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
