require 'pathname'

class ScaleDown::Image

  # This class should only
  #   load an image
  #   ensure an RGB colorspace
  #   correct the orientation
  #   scale the image to the dimensions
  #   save the scaled image to the specified path
  #
  # This is not the place for any other logic.
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
    load_file(properties[:file]) do |file|
      resize(file, properties[:options])
      fix_color_space(file)

      @valid = write(file, properties[:out])
    end
  end

  def load_file(file_path)
    self.class.validate_file_size(file_path)
    begin
      file = Magick::Image.read(file_path).first
      unless file.nil?
        yield file
        # file.destroy!
      end
    rescue Magick::ImageMagickError => e
    end
  end

  def geometry(properties)
    self.class.geometry properties
  end

  def valid?
    @valid ||= false
  end

  protected

    def fix_color_space(file)
      if file.colorspace == Magick::CMYKColorspace
        file.add_profile "#{File.expand_path(File.dirname(__FILE__))}/../../color_profiles/sRGB.icm"
        file = file.quantize 2**24, Magick::RGBColorspace
      end
    end

    def resize(file, properties)
      geo = geometry(properties)
      file.auto_orient! unless Hash[file.get_exif_by_entry("Orientation")]["Orientation"].nil?
      if properties[:crop]
        file.crop_resized!(geo.width, geo.height, Magick::CenterGravity)
      else
        file.change_geometry!(geo) {|cols, rows, img| img.resize!(cols,rows)}
      end
    end

    def write(file, file_out)
      path = Pathname.new(file_out).dirname.to_s
      FileUtils.mkdir_p path unless FileTest.directory? path

      file.write(file_out) { self.quality = 85; }
      true
    end
end
