class ScaleDown::Dispatcher

  # Controls flow to ensure that the file exists and has the proper HMAC signature.

  class << self

    def process(params)
      dispatcher = new(params)

      ScaleDown.logger.info "Dipatcher#process #{dispatcher.root_path}"
      $0= "scale_down Dipatcher#process #{dispatcher.root_path}"

      return ["Missing file", 404] unless dispatcher.root_file_exists?
      return [dispatcher.redirect_path, dispatcher.redirect_code] if dispatcher.scaled_file_exists?

      return ["Invalid HMAC signature", 403] unless dispatcher.valid_hmac?
      return ["File failed to scale. The file may be corrupt.", 500] unless dispatcher.scale

      [dispatcher.redirect_path, dispatcher.redirect_code]
    end

    # TODO return a JSON response with a full set of image details
    def info(relative_path)
      path = [ScaleDown.public_folder, relative_path].join("/")
      if File.exists?(path)
        GC.start
        image = Magick::Image.read(path).first
        [image.columns, image.rows].join('x')
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

  def redirect_code
    @params[:filename].match(/(png|jpg)$/) ? 302 : 301
  end

  def redirect_path
    ["/"+@params[:path], @params[:geometry], scaled_filename].join("/")
  end

  def root_file_exists?
    File.exists? root_path
  end

  def scaled_file_exists?
    File.exists? scaled_file_path
  end

  def root_path
    root = @params[:path].gsub(/\/scaled$/,"")
    File.join(ScaleDown.public_folder, root, @params[:filename])
  end

  def scaled_file_path
    File.join(ScaleDown.public_folder, redirect_path)
  end

  def scaled_filename
    "#{filename}.#{scaled_extension}"
  end

  def filename
    @params[:filename].split(".")[0...-1].join(".")
  end

  def scaled_extension
    ext = @params[:filename].split(".").last
    ext == "png" ? ext : "jpg"
  end
end
