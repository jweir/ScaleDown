require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class ScaleDown::Test < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ScaleDown::Controller
  end

  def valid_get(path)
    get "#{path}?#{ScaleDown.hmac(path)}"
  end

  def copy(f, to, num)
    FileUtils.mkdir_p("/tmp/scale_down/test_images/example_#{num}")
    FileUtils.cp fixture_path("files/#{f}"), "/tmp/scale_down/test_images/example_#{num}/#{to}"
  end

  context "ScaleDown" do
    setup do
      ScaleDown.hmac_key    = "secret"
      ScaleDown.hmac_method = HMAC::SHA1
      ScaleDown.hmac_length = 8
      ScaleDown.public_folder = "/tmp/scale_down"
    end

    context "HMAC" do
      setup do
        hmac = HMAC::SHA1.new("secret").update("/file/path/400x300-crop/filename.png").to_s

        @params = {
          :path     => "file/path",
          :filename => "filename.png",
          :target   => "400x300-crop",
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
        copy 'graphic.png', 'graphic.png', 1
        copy 'invalid_jpeg.jpg', 'invalid_jpeg.jpg', 2
      end

      teardown do
        FileUtils.rm_r("/tmp/scale_down")
      end

      context "homepage" do
        should "show the version" do
          get "/"
          assert_match ScaleDown::VERSION, last_response.body
        end

        should "show the labels" do
          ScaleDown.labels = {
            :medium => "100x100",
            :large  => "800x800"
          }

          get "/"
          assert_match "medium 100x100", last_response.body
          assert_match "large 100x100", last_response.body
        end
      end

      should "get image info" do
        copy 'cmyk.tif', 'long-name.tiff', 1
        get "/test_images/example_1/#{CGI.escape 'long-name.tiff'}/info"
        assert_equal "300x500", last_response.body
      end

      should "get an image with a geometry and scale it" do
        valid_get '/test_images/example_1/scaled/400x300-cropped/graphic.png'
        assert_equal 200, last_response.status
        assert File.exists?("/tmp/scale_down/test_images/example_1/scaled/400x300-cropped/graphic.png")
      end

      should "consider + in filenames as spaces" do
        copy 'graphic.png', 'name space.png', 3

        hmac = ScaleDown.hmac '/test_images/example_3/scaled/400x300/name space.png'
        get "/test_images/example_3/scaled/400x300/name+space.png?#{hmac}"
        assert_equal 200, last_response.status
        assert File.exists?("/tmp/scale_down/test_images/example_3/scaled/400x300/name space.png")
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

      context "using a label" do
        setup do
          ScaleDown.labels = { "very-large" => "600x600" }
        end

        should "get an image with a label and scale it" do
          get '/test_images/example_1/scaled/very-large/graphic.png'
          assert_equal 200, last_response.status
          assert File.exists?("/tmp/scale_down/test_images/example_1/scaled/very-large/graphic.png")

          get '/test_images/example_1/scaled/very-large-crop/graphic.png'
          assert_equal 200, last_response.status
          assert File.exists?("/tmp/scale_down/test_images/example_1/scaled/very-large-crop/graphic.png")
        end

        context "that does not exist" do
          should "return an error" do
            get '/test_images/example_1/scaled/toosmall/graphic.png'
            assert_equal 403, last_response.status
          end
        end
      end
    end
  end
end
