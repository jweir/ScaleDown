require File.expand_path(File.dirname(__FILE__))+'/test_helper'

require 'cgi'

class ScaleDown::Test < Test::Unit::TestCase

  def signed_image_url(path, filename, geometry)
    hmac = HMAC::SHA1.new("secret").update([path, 'scaled', geometry, filename].join("/")).to_s[0...8]
    "http://images.myserver.com#{[path, 'scaled', geometry, CGI.escape(filename)].join("/")}?#{hmac}"
  end

  setup do
    ScaleDown.hmac_key    = "secret"
    ScaleDown.hmac_method = HMAC::SHA1
    ScaleDown.hmac_length = 8
    ScaleDown.public_folder = "/tmp"
  end

  should "create a URL with the HMAC signature" do
    hmac = ScaleDown.hmac("/images/scaled/400x300-cropped/graphic.png")
    assert_equal\
      "http://images.myserver.com/images/scaled/400x300-cropped/graphic.png?#{hmac}",
      signed_image_url("/images","graphic.png","400x300-cropped")
  end

  should "create a URL when the filename has URI break characters" do
    filename = "# !%23?.png"
    hmac = ScaleDown.hmac("/images/scaled/400x300-cropped/#{filename}")
    assert_equal\
      "http://images.myserver.com/images/scaled/400x300-cropped/#{CGI.escape filename}?#{hmac}",
      signed_image_url("/images", filename, "400x300-cropped")
  end
end
