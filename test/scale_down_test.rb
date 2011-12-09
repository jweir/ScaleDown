require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class ScaleDown::Test < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ScaleDown::Controller
  end

  def valid_get(path)
    get "#{path}?#{ScaleDown.hmac(path)}"
  end

  context "ScaleDown" do
    setup do
      ScaleDown.hmac_key    = "secret"
      ScaleDown.hmac_method = HMAC::SHA1
      ScaleDown.hmac_length = 8
      ScaleDown.public_path = "/tmp/scale_down"
    end

    context "HMAC" do
      setup do
        hmac = HMAC::SHA1.new("secret").update("/file/path/400x300-crop/filename.png").to_s

        @params = {
          :path     => "file/path",
          :filename => "filename.png",
          :geometry => "400x300-crop",
          :hmac     => hmac[0...8]
        }
      end

      should "validate when the params match the HMAC signature" do
        assert ScaleDown.valid_hmac?(@params)
      end

      should "not validate when the params do not match the HMAC signature" do
        assert !ScaleDown.valid_hmac?(@params.merge(:path => "file/different"))
      end
    end

    context "integration test" do
      setup do
        FileUtils.mkdir_p("/tmp/scale_down/test_images/example_1")
        FileUtils.cp fixture_path("files/graphic.png"), "/tmp/scale_down/test_images/example_1/graphic.png"
        FileUtils.mkdir_p("/tmp/scale_down/test_images/example_2")
        FileUtils.cp fixture_path("files/invalid_jpeg.jpg"), "/tmp/scale_down/test_images/example_2/invalid_jpeg.jpg"
      end

      teardown do
        FileUtils.rm_r("/tmp/scale_down")
      end

      should "get image info" do
        FileUtils.cp fixture_path("files/cmyk.tif"), "/tmp/scale_down/test_images/example_1/long name .tiff"
        get "/test_images/example_1/#{CGI.escape 'long name .tiff'}/info"
        assert_equal "300x500", last_response.body
      end

      should "get an image and scale it" do
        valid_get '/test_images/example_1/scaled/400x300-cropped/graphic.png'
        assert_equal 200, last_response.status
        assert File.exists?("/tmp/scale_down/test_images/example_1/scaled/400x300-cropped/graphic.png")
      end

      should "get a nonexistant image and return a 404" do
        valid_get "/test_images/example_none/scaled/400x300/image.jpg"
        assert_equal 404, last_response.status
      end

      should "get an invalid image and return a 500" do
        valid_get '/test_images/example_2/scaled/400x300-cropped/invalid_jpeg.jpg'

        assert_equal 500, last_response.status
        assert !File.exists?("/tmp/scale_down/test_images/example_2/scaled/400x300-cropped/invalid_jpeg.jpg")
      end
    end
  end
end
