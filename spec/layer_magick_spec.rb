require "spec_helper"

describe LayerMagick do
  it "should create an image" do
      # create a document 400x450
    doc = LayerMagick::Document.new(width: 400, height: 450) do
      # add a white fill layer
      fill('white')

      # add an image layer from a remote source on top of that
      # resize it and place it at to x: 25, y: 25
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
    FileUtils.mv image.path, "#{ENV['HOME']}/Desktop/layer_magick_test1.png"
    system "open ~/Desktop/layer_magick_test1.png"


    thumbnail = doc.save_thumbnail_as('test_thm.png', 111, 73)
    FileUtils.mv thumbnail.path, "#{ENV['HOME']}/Desktop/layer_magick_test2.png"
    system "open ~/Desktop/layer_magick_test2.png"

  end

  it "should work with local files too" do
    clown = File.expand_path(File.dirname(__FILE__)) + '/clown.jpg'

    doc = LayerMagick::Document.new(width: 400, height: 450) do
      # add a white fill layer
      fill('white')
      image(clown, :offset => [50,50]) do |img|
        img.rotate! -5
      end
    end

    image = doc.save_as('test.png')
    FileUtils.mv image.path, "#{ENV['HOME']}/Desktop/layer_magick_test1.png"
    system "open ~/Desktop/layer_magick_test1.png"
  end
end