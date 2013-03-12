# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'layer_magick/version'

Gem::Specification.new do |gem|
  gem.name          = "layer_magick"
  gem.version       = LayerMagick::VERSION
  gem.authors       = ["John Butler"]
  gem.email         = ["johnnypez@gmail.com"]
  gem.description   = %q{A simple wrapper for RMagick that lets us do what we do in style}
  gem.summary       = %q{A simple wrapper for RMagick that lets us do what we do in style}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rmagick"
  gem.add_development_dependency "rspec"
end
