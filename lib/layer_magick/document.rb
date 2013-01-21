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
        self.gravity = Magick::CenterGravity
        self.font = options[:font] if options[:font]
        yield(self) if block_given?
      end.first

      # position the image
      img.page = Magick::Rectangle.new(img.rows, img.columns, left, top)

      add_layer img
    end

    def image(path, options = {}, &block)
      path = Temp::Remote.new(path).path if path.match(/^(https?|ftp):/)
      left, top = options[:offset] || [0,0]

      img = Magick::Image.read(path).first

      #position the image
      img.page = Magick::Rectangle.new(img.rows,img.columns,left,top)
      
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

    def fill(color = 'transparent')
      add_layer new_layer(color)
    end

    def flattened
      @flattened ||= @layers.flatten_images
    end

    # e.g.
    # save_as('foo.png')
    # => Tempfile
    def write_temp(name)
      temp = Temp::Local.new(name)
      write(temp.path)
      temp
    end

    def write(path)
      flattened.write(path)
      File.open(path)
    end

    # returns a new Magick::Image
    # up to you what you do with that
    def thumbnail(name, width, height, gravity = Magick::CenterGravity, &block)
      thm = flattened.resize_to_fill(width,height,gravity)
      temp = Temp::Local.new(name)
      thm.write(temp.path)
      temp
    end

    private

    def add_layer(layer)
      @flattened = nil
      @layers << layer
      layer
    end

    def new_layer(fill = 'transparent')
      Magick::Image.new(@width,@height) do
        self.background_color = fill
      end
    end

  end
end