require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class ScaleDown::Controller::Test < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ScaleDown::Controller
  end

  context "parsing a request" do
    should "have an image path" do
      ScaleDown::Dispatcher.expects(:process).with(
        :path     => "user/path/scaled",
        :filename => "filename.png",
        :geometry => "400x300-crop-grayscale",
        :hmac     => "HMAC").
      returns ["path","status"]

      get '/user/path/scaled/400x300-crop-grayscale/filename.png?HMAC'
    end
  end

  context "a valid request" do
    should "redirect to the image path" do
      ScaleDown::Dispatcher.expects(:process).returns ["/image-path", 302]
      get "/path/geo/filename?hmac"

      assert_equal 200, last_response.status
    end
  end

  context "an invalid request" do

    should "respond with a 403 and error message" do
      ScaleDown::Dispatcher.expects(:process).returns ["Error description", 403]

      get "/path/geo/filename?hmac"

      assert_equal 403, last_response.status
      assert_match "Error", last_response.body
    end
  end

  context "get dimensions" do
    context "for image which exists" do
      setup do
        ScaleDown::Dispatcher.expects(:info).with("image/path/image.jpg").returns "400x300"
      end

      should "return the width and height as json" do
        get "/image/path/image.jpg/info"

        assert_equal 200, last_response.status
        assert_equal "400x300", last_response.body
      end
    end

    context "for a non-existant image" do
      setup do
        ScaleDown::Dispatcher.expects(:info).with("image/path/image.jpg").returns nil
      end

      should "respond with a 404" do
        get "/image/path/image.jpg/info"
        assert_equal 404, last_response.status
      end
    end
  end
end
