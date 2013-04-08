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
        :target   => "400x300-crop-grayscale",
        :hmac     => "HMAC").
        returns ["path","status"]

        get '/user/path/scaled/400x300-crop-grayscale/filename.png?HMAC'
    end
  end

  context "a valid request" do
    should "respond with the file" do
      ScaleDown::Dispatcher.expects(:process).returns ["/image-path", 302]
      get "/path/geo/filename?hmac"

      assert_equal 200, last_response.status
    end

    should "redirect to the image path for non png or jpg original imags" do
      ScaleDown::Dispatcher.expects(:process).returns ["/image-path", 301]
      get "/path/geo/filename?hmac"

      assert_equal 301, last_response.status
      assert_equal "http://example.org/image-path", last_response["Location"]
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
        ScaleDown::Info.expects(:new).with("image/path/image.jpg").returns mock(missing?: false, to_json: 'json_blob')
      end

      should "return the width and height as json" do
        get "/image/path/image.jpg/info"

        assert_equal 200, last_response.status
        assert_equal "json_blob", last_response.body
      end
    end

    context "for a non-existant image" do
      setup do
        ScaleDown::Info.expects(:new).with("image/path/image.jpg").returns mock(missing?: true)
      end

      should "respond with a 404" do
        get "/image/path/image.jpg/info"
        assert_equal 404, last_response.status
      end
    end
  end
end
