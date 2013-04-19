require "RMagick"
require "pathname"
require "layer_magick/temp"
require "layer_magick/version"
require "layer_magick/document"

module LayerMagick
  # Your code goes here...
  class ImageNotFound < Exception; end
  class InvalidType < Exception; end
end
