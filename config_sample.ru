require 'lib/scale_down'

ScaleDown::Scaler.hmac_key    = "secret"
ScaleDown::Scaler.hmac_method = HMAC::MD5
ScaleDown::Scaler.hmac_length = 8
ScaleDown::Scaler.root_path   = File.expand_path(File.dirname(__FILE__))+"/public"

run ScaleDown::Controller
