require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class ScaleDown::Test < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ScaleDown::Controller
  end

  def valid_get(path)
    get "/#{path}/#{hmac(path, "secret")[0...8]}" 
  end    

  context "integration test" do
    setup do
      ScaleDown::Scaler.hmac_key    = "secret"
      ScaleDown::Scaler.hmac_method = HMAC::MD5
      ScaleDown::Scaler.hmac_length = 8
      ScaleDown::Scaler.root_path   = "/tmp/scale_down"

      FileUtils.mkdir_p("/tmp/scale_down/test_images/example_1") 
      FileUtils.cp tests_path("files/graphic.png"), "/tmp/scale_down/test_images/example_1/graphic.png"
      FileUtils.mkdir_p("/tmp/scale_down/test_images/example_2") 
      FileUtils.cp tests_path("files/invalid_jpeg.jpg"), "/tmp/scale_down/test_images/example_2/invalid_jpeg.jpg"
    end

    teardown do
      FileUtils.rm_r("/tmp/scale_down")
    end

    should "get an image and scale it" do
      valid_get 'test_images/example_1/graphic.png/400x300-cropped' 
      assert_equal 301, last_response.status
      assert_equal "/test_images/example_1/scaled/graphic-400x300-cropped.png", last_response["Location"]
      assert File.exists?("/tmp/scale_down/test_images/example_1/scaled/graphic-400x300-cropped.png")
    end

    should "get a nonexistant image and return a 404" do
      valid_get "test_exmaples/example_none/image.jpg"
      assert_equal 404, last_response.status
    end

    should "get an invalid image and return a 403" do
      valid_get 'test_images/example_2/invalid_jpeg.jpg/400x300-cropped'

      assert_equal 403, last_response.status
      assert !File.exists?("/tmp/scale_down/test_images/example_2/scaled/invalid_jpeg-400x300-cropped.jpg")
    end
  end
end

