require 'scale_down'

ScaleDown.tap do |config|

  # This is the shared secret.  Use something strong
  # Perhaps a visit to http://www.random.org/strings/?num=10&len=20&digits=on&upperalpha=on&format=html&rnd=new
  config.hmac_key    = "secret"

  # You can use a different HMAC, see the ruby-hmac gen
  config.hmac_method = HMAC::SHA1

  # The length of the HMAC signature to use
  config.hmac_length = 8

  # The root path to the images
  config.root_path   = File.expand_path(File.dirname(__FILE__))+"/public"

  # The location of the public directory for serving static files
  # This might be redudant since it will always, maybe, maybe not, be the same as root_path
  config.public_path = "#{File.expand_path(File.dirname(__FILE__))}/public"

end

run ScaleDown::Controller
