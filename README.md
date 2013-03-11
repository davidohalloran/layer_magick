# LayerMagick

A wrapper for simplifying the creation of layered compositions with RMagick.
Saves tempfiles suitable for use with Paperclip in our Heroku workflow.

## Installation

Add this line to your application's Gemfile:

    gem 'layer_magick', :git => "git://github.com/Betapond/layer_magick.git"

And then execute:

    $ bundle

## Usage

```ruby
  # create a document 400x450
  doc = LayerMagick::Document.new(width: 400, height: 450) do
    # add a white fill layer
    fill('white')

    # add an image layer from a remote source (can also be a local path) on top of that
    # resize it and place it at to x: 25, y: 25
    # optionally takes a block which passes through an Magick::Image
    # with which you can do wonderous things http://www.imagemagick.org/RMagick/doc/image1.html
    image("http://baconmockup.com/400/400", size: '350x', offset: [25,25])

    # add a text layer on top of that
    # font can be a system font or a path to a font
    textarea("I love bacon!", font: 'Impact', offset: [0, 390], color: 'black') do |text|
      text.pointsize = 18
    end
  end

  # save the image to a temp file
  # we just want to output tmp files when working on Heroku
  # doc.write_temp returns a LayerMagick::Temp::Local
  # a subclass of ::Tempfile with content type attributes that Paperclip looks for
  image = doc.save_as('test.png')

  # save a thumbnail
  # takes an optional 4th parameter Magick::Gravity
  thumbnail = doc.save_thumbnail_as('test_thm.png', 111, 73)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
