require 'pathname'

class ScaleDown::Image

  include Magick

  class << self

    def scale(properties)
      new(properties).valid?
    end

    def geometry(properties)
      validate_geometry Magick::Geometry.new(properties[:width], properties[:height], nil, nil, ">")
    end

    # Ensures that the dimensions are not both 'auto' and within the max dimensions
    def validate_geometry(geometry)
      geometry.tap do |g|
        total = g.width + g.height
        raise ScaleDown::InvalidGeometry if total == 0
        raise ScaleDown::InvalidGeometry if g.width > ScaleDown.max_dimensions[0] || g.height > ScaleDown.max_dimensions[1]
      end
    end

    def validate_file_size(file_path)
      unless File.size(file_path) < ScaleDown.max_file_size
        raise ScaleDown::FileSizeTooLarge
      end
    end
  end

  def initialize(properties = {})
    @file     = load_file(properties[:file])
    @out      = properties[:out]
    @geometry = geometry(properties[:options])
    @options  = properties[:options]
    @wrote    = false

    save if @file
  end

  def load_file(file_path)
    self.class.validate_file_size(file_path)
    begin
      Magick::Image.read(file_path).first
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
