require 'scale_down'

ScaleDown.tap do |config|

  # The location of the public directory where the original are located
  # This directory will also be the target for writing scaled images
  # Most likely this will be a symbolic link to a shared directory
  config.public_path = "#{File.expand_path(File.dirname(__FILE__))}/public"

  # Labels are predefined geometries.
  # They have the advantage of not requiring an HMAC signature in the URL
  # The keys should be strings, not symbols
  config.labels = {
    "thumbnail" => "100x100"
  }

  # an array of the max width and height an image can be scaled, in pixels.
  config.max_dimensions = [1200,1200]

  # the max file size allowed for the original file to be scaled, in bytes
  scaledown.max_file_size  = 25 * 1_048_576 # 25 Megabytes

  # This is the shared secret for generating and verifying the HMAC signature.
  # This string would be shared with any application generating URLS for scaled images
  # http://www.random.org/strings/
  config.hmac_key    = "secret"

  # Change the method for generating the HMAC
  config.hmac_method = HMAC::SHA1

  # How long of an HMAC signature is required
  config.hmac_length = 8

  # Optional logger
  # config.logger = YOUR_LOGGER
end

run ScaleDown::Controller
