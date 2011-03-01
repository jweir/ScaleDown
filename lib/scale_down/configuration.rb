module ScaleDown
  class << self

    # Defines the method to use for generating an HMAC
    # For example
    #   ScaleDown.hmac_method = HMAC::SHA2
    # Default HMAC::SHA1
    attr_accessor :hmac_method
    ScaleDown.hmac_method = HMAC::SHA1

    # The shared secret for generating the hmac
    attr_accessor :hmac_key

    # How many characters of the HMAC are used for validation
    # Default 8
    attr_accessor :hmac_length
    ScaleDown.hmac_length = 8

    # An array of the max width and height an image can be scaled, in pixels.
    # [800,600] would limit scaling operations to 800px wide by 600px tall
    # Default [1200,1200]
    attr_accessor :max_dimensions
    ScaleDown.max_dimensions = [1200,1200]

    # The max file size allowed for the file to be scaled, in bytes
    # Defaults 10 megabytes
    attr_accessor :max_file_size
    ScaleDown.max_file_size  = 10 * 1_048_576

    # The location of the public path for you application
    # +Must be set+
    attr_accessor :public_path

    def public_path=(str)
      @public_path = str
      ScaleDown::Controller.public = str
    end

    def logger=(logger)
      @logger = logger
    end

    def logger
      @logger || Logger.new("/dev/null")
    end
  end
end
