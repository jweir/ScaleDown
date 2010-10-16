require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class Controller::Test < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controller
  end

  context "parsing a request" do

    should "have an image path" do
      Scaler.expects(:request).with(
        :path     => "user/path",
        :filename => "filename.png",
        :geometry => "400x300-cropped-grayscale",
        :hmac     => "HMAC").
      returns ["path","status"]

      get '/user/path/filename.png/400x300-cropped-grayscale/HMAC'
    end
  end

  context "a valid request" do

    should "redirect to the image path" do
      Scaler.expects(:request).returns ["/image-path", 301]
      get "/path/filename/geo/hmac"

      assert_equal 301, last_response.status
      assert_equal "/image-path", last_response["Location"]
    end
  end

  context "an invalid request" do
    should "respond with a 403 and error message" do
      Scaler.expects(:request).returns ["Error description", 403]

      get "/path/filename/geo/hmac"

      assert_equal 403, last_response.status
      assert_match "Error", last_response.body
    end
  end
end
