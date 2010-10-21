require 'pathname'

class ScaleDown::Image
  include Magick

  class << self

		def max_size
			10 * 1_048_576
		end

    def scale(properties)
      new(properties).valid?
    end
    
    def geometry(properties)
      Magick::Geometry.new(properties[:width], properties[:height], nil, nil, ">")
    end
  end

  def initialize(properties = {})
    @file     = load_file(properties[:file])
    @out      = properties[:out]
    @geometry = geometry(properties[:options])
    @options  = properties[:options]
    @wrote    = false

    save if (@file && (File.size(properties[:file]) < self.class.max_size))
  end

  def load_file(filepath)
    begin
      Magick::Image.read(filepath).first
    rescue Magick::ImageMagickError => e
      return nil
    end
  end 

  def geometry(properties)
    self.class.geometry properties
  end

  def valid?
    @wrote
  end

  protected

    def save 
      path = Pathname.new(@out).dirname.to_s
      FileUtils.mkdir_p path unless FileTest.directory? path
      resize
      fix_color_space
      write
    end

    def fix_color_space
      if @file.colorspace == Magick::CMYKColorspace
        @file.add_profile "#{File.expand_path(File.dirname(__FILE__))}/../../color_profiles/sRGB.icm"
        @file = @file.quantize 2**24, Magick::RGBColorspace
      end
    end

    def resize
      @file.auto_orient!
      if @options[:crop]
        @file.crop_resized!(@geometry.width, @geometry.height, Magick::CenterGravity)
      else
        @file.change_geometry!(@geometry) {|cols, rows, img| img.resize!(cols,rows)}
      end
    end

    def write
      @file.write(@out) { self.quality = 85 }
      @wrote = true
    end
end
