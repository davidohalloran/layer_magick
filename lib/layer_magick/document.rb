module LayerMagick
  class Document
    attr_reader :width, :height, :layers
    attr_accessor :fonts_dir
    def initialize(options = {}, &block)
      @width = options[:width] || 300
      @height = options[:height] || 300
      @background = options[:background] || 'transparent'
      @layers = Magick::ImageList.new
      fill @background
      instance_eval(&block) if block_given?
    end

    # textarea - add a text layer
    # param: str - the text string
    # param: options
    #   size: a Magick::Geometry string
    #   font: system font or path to ttf
    # param: block
    #   provides access to generated Magick::Image
    #   where you can do fancy things http://www.imagemagick.org/RMagick/doc/image1.html
    # usage:
    # => textarea "I love bacon!", font" 'Impact', 
    def textarea(str, options = {}, &block)
      options = {:width => @width}.merge(options)
      size = "#{options[:width]}x#{options[:height]}"
      left, top = options[:offset] || [0,0]
      
      img = Magick::Image.read("caption:#{str}") do
        # see http://www.imagemagick.org/RMagick/doc/info.html for options
        self.size = size
        self.background_color = 'transparent'
        self.gravity = options[:gravity] || Magick::CenterGravity
        self.font = options[:font] if options[:font]
        self.fill = options[:color] || 'red'
        yield(self) if block_given?
      end.first

      # position the image
      img.page = Magick::Rectangle.new(img.columns,img.rows,left,top)

      add_layer img
    end

    def image(path, options = {}, &block)
      path = Temp::Remote.new(path).path if path.match(/^(https?|ftp):/)
      left, top = options[:offset] || [0,0]

      img = Magick::Image.read(path).first

      #position the image
      img.page = Magick::Rectangle.new(img.columns,img.rows,left,top)
      
      # adjust size
      if options[:size]
        img.change_geometry!(options[:size]) { |cols, rows, i|
          i.resize!(cols, rows)
        }
      end
      
      # give the user the chance to do more with the image
      yield(img) if block_given?

      add_layer img
    end

    def fill(color = 'transparent', &block)
      img = Magick::Image.new(@width, @height) do
        self.background_color = color
      end
      yield(img) if block_given?
      add_layer img
    end

    def flattened
      @flattened ||= @layers.flatten_images
    end

    # e.g.
    # save_as('foo.png')
    # => LayerMagick::Temp::Local
    def save_as(name)
      write_temp name, flattened
    end

    # e.g.
    # save_thumbnail_as('foo_thumbnail.png')
    # => LayerMagick::Temp::Local
    def save_thumbnail_as(name, width, height, gravity = Magick::CenterGravity)
      write_temp name, flattened.resize_to_fill(width,height,gravity)
    end

    private

    def add_layer(layer)
      @flattened = nil
      @layers << layer
      layer
    end

    def write_temp(name, image)
      temp = Temp::Local.new(name)
      image.write(temp.path)
      temp
    end

  end
end