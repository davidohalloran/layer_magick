require 'tempfile'
require 'open-uri'
require 'digest/sha1'
module LayerMagick

  # Tempfiles that play nice with paperclip

  module Temp

    # Usage
    # file = Temp::Local.new('foo.jpg')
    class Local < ::Tempfile
    
      attr_reader :original_filename

      def initialize(name, tmpdir = Dir::tmpdir)
        @original_filename  = File.basename(name)
        super [File.basename(name, '.*'), File.extname(name)], tmpdir
      end
     
      def content_type
        mime = `file --mime -br #{self.path}`.strip
        mime = mime.gsub(/^.*: */,"")
        mime = mime.gsub(/;.*$/,"")
        mime = mime.gsub(/,.*$/,"")
        mime
      end
      
    end

    # Usage:
    # file = Temp::Remote.new('http://www.example.com/foo.jpg')
    class Remote < Local
     
      def initialize(path, tmpdir = Dir::tmpdir)
        @remote_path        = path
        super Digest::SHA1.hexdigest(path), tmpdir
        binmode
        fetch
      end
     
      def fetch
        string_io = OpenURI.send(:open, @remote_path)
        self.write string_io.read
        self.rewind
        self
      end
      
    end

  end
end