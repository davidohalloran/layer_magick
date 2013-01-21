require "spec_helper"

describe LayerMagick do
  it "should create an image" do
    doc = LayerMagick::Document.new(width: 400, height: 450) do
      fill('white')
      
      image("http://baconmockup.com/400/400", size: '350x', offset: [25,25])
      
      textarea("I love bacon!", font: 'Impact', offset: [0, 410]) do |text|
        text.pointsize = 18
      end

    end
    out = doc.write_temp('test.png')
    FileUtils.mv out.path, "#{ENV['HOME']}/Desktop/layer_magick_test1.png"
    system "open ~/Desktop/layer_magick_test1.png"
  end
end