require 'scale_down'

ScaleDown.tap do |config|

  # The location of the public directory where the original are located
  # This directory will also be the target for writing scaled images
  # Most likely this will be a symbolic link to a shared directory
  config.public_path = "#{File.expand_path(File.dirname(__FILE__))}/public"
  
  # Labels are predefined geometries
  config.labels = {
    :thumbnail => "100x100"
  }
  
  # This is the shared secret for generating and verifying the HMAC signature.
  # http://www.random.org/strings/?num=10&len=20&digits=on&upperalpha=on&format=html&rnd=new
  config.hmac_key    = "secret"

  # Change the method for generating the HMAC
  config.hmac_method = HMAC::SHA1

  # How long of an HMAC signature is required
  config.hmac_length = 8

  # Logger
  # TODO
end

run ScaleDown::Controller
