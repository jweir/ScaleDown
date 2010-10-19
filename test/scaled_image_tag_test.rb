require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class ScaleDown::Test < Test::Unit::TestCase

  def scaled_image_src(url)
    hmac = HMAC::MD5.new("secret").update(url).to_s[0...8]
    "http://images.myserver.com#{url}/#{hmac}"
  end

  setup do
    ScaleDown::Scaler.hmac_key    = "secret"
    ScaleDown::Scaler.hmac_method = HMAC::MD5
    ScaleDown::Scaler.hmac_length = 8
    ScaleDown::Scaler.root_path   = "/tmp"
  end

  should "create a URL with the HMAC signature" do
    hmac = ScaleDown::Scaler.hmac("/images/graphic.png/400x300-cropped")
    assert_equal "http://images.myserver.com/images/graphic.png/400x300-cropped/#{hmac}", scaled_image_src("/images/graphic.png/400x300-cropped")
  end
end


