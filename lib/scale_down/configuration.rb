module ScaleDown
  class << self

    # Defines the method to use for generating an HMAC
    # For example
    #   ScaleDown.hmac_method = HMAC::SHA2
    attr_accessor :hmac_method

    # The shared secret for generating the hmac
    attr_accessor :hmac_key

    # How many characters of the HMAC are used for validation
    attr_accessor :hmac_length

    # An array of the max width and height an image can be scaled, in pixels.
    # [800,600] would limit scaling operations to 800px wide by 600px tall
    # Default [1200,1200]
    attr_accessor :max_dimensions

    # The max file size allowed for the file to be scaled, in bytes
    # Defaults to  10 * 1_048_576
    attr_accessor :max_file_size

    # The location of the public path for you application
    # +Must be set+
    attr_accessor :public_path
    def public_path=(str)
      @public_path = str
      ScaleDown::Controller.public = str
    end

    # Defaults
    ScaleDown.max_file_size  = 10 * 1_048_576
    ScaleDown.max_dimensions = [1200,1200]

    def logger=(logger)
      @logger = logger
    end

    def logger
      @logger || Logger.new("/dev/null")
    end
  end
end
