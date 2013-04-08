require 'json'

# Returns a json object with the height, width attributes
class ScaleDown::Info

  def initialize(relative_path)
    path = [ScaleDown.public_folder, relative_path].join("/")
    if File.exists?(path)
      GC.start
      @image_list = Magick::Image.read(path)
      @image = @image_list.first
    else
      @missing = true
    end
  end

  def missing?
    @missing == true
  end

  def hash
    {
      height: @image.rows,
      width: @image.columns,
      # is this an animated GIF or other file
      animated: @image_list.size > 1
    }
  end

  def to_json
    JSON hash
  end
end
