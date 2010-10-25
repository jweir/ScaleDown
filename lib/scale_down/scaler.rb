class ScaleDown::Scaler

  class << self

    def process(params)
      scaler = new(params)

      return ["Missing file", 404] unless scaler.root_file_exists?
      return [scaler.redirect_path, 301] if scaler.scaled_file_exists?

      if scaler.valid_hmac? && scaler.scale
        [scaler.redirect_path, 301]
      else
        ["Error message", 403]
      end
    end

    def info(relative_path)
      path = [ScaleDown.root_path, relative_path].join("/")
      if File.exists?(path)
        image = Magick::Image.read(path).first
        [image.columns, image.rows].join("x")
      else
        nil
      end
    end
  end

  def initialize(params)
    @params = params
  end

  def image_options
    dimensions, *options = @params[:geometry].split("-")
    width, height = dimensions.split("x")
    {:height => height.to_i, :width => width.to_i}.tap do |o|
      options.each {|k| o[k.to_sym] = true}
    end
  end

  def scale
    ScaleDown::Image.scale \
      :file    => root_path,
      :out     => scaled_file_path,
      :options => image_options
  end

  def valid_hmac?
    ScaleDown.valid_hmac?(@params)
  end

  def redirect_path
    ["/"+@params[:path], "scaled", scaled_filename].join("/")
  end

  def root_file_exists?
    File.exists? root_path
  end

  def scaled_file_exists?
    File.exists? scaled_file_path
  end

  def root_path
    File.join(ScaleDown.root_path, @params[:path], @params[:filename])
  end

  def scaled_file_path
    File.join(ScaleDown.root_path, redirect_path)
  end

  def scaled_filename
    "#{filename}-#{@params[:geometry]}.#{scaled_extension}"
  end

  def filename
    @params[:filename].split(".")[0...-1].join(".")
  end

  def scaled_extension
    ext = @params[:filename].split(".").last
    ext == "png" ? ext : "jpg"
  end
end
