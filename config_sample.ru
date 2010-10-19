require 'scale_down'

ScaleDown.tap do |config|
  config.hmac_key    = "secret"
  config.hmac_method = HMAC::SHA1
  config.hmac_length = 8
  config.root_path   = File.expand_path(File.dirname(__FILE__))+"/public"
end

run ScaleDown::Controller
