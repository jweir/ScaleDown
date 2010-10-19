require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class ScaleDown::Scaler::Test < Test::Unit::TestCase

  context "Scaler::Test" do
    setup do
      ScaleDown.hmac_key    = "secret"
      ScaleDown.hmac_method = HMAC::MD5
      ScaleDown.hmac_length = 8
      ScaleDown.root_path   = "/tmp"

      hmac = HMAC::MD5.new("secret").update("file/path/filename.png/400x300-crop").to_s

      @params = {
        :path     => "file/path",
        :filename => "filename.png",
        :geometry => "400x300-crop",
        :hmac     => hmac[0...8]
      }
    end

    context "instance" do
      setup do
        @scaler = ScaleDown::Scaler.new @params
      end

      should "validate the HMAC" do
        ScaleDown.expects(:valid_hmac?).with(@params).returns true
        assert @scaler.valid_hmac?
      end

      should "determine root file existance" do
        File.expects(:exists?).with("/tmp/file/path/filename.png").returns true
        assert @scaler.root_file_exists?
      end

      should "deterimine the scaled image's existance" do
        File.expects(:exists?).with("/tmp/file/path/scaled/filename-400x300-crop.png").returns true
        assert @scaler.scaled_file_exists?
      end

      should "parse the geometry params into options" do
        assert_equal({:width => 400, :height => 300, :crop => true}, @scaler.image_options)
      end

      should "have a redirect path" do
        assert_equal "/file/path/scaled/filename-400x300-crop.png", @scaler.redirect_path
      end

      should "process the image" do
        ScaleDown::Image.expects(:scale).with(
          :file    => @scaler.root_path,
          :out     => @scaler.scaled_file_path,
          :options => @scaler.image_options).returns true

          assert @scaler.scale
      end

      should "default to a jpg out file" do
        ["jpg", "tga", "tif", "pdf", "psd"].each do |ext|
          scaler = ScaleDown::Scaler.new @params.merge(:filename => "test.#{ext}")
          assert_match /\.jpg$/, scaler.scaled_file_path
        end
      end

      should "use a png for png graphics" do
        scaler = ScaleDown::Scaler.new @params.merge(:filename => "test.png")
        assert_match /\.png$/, scaler.scaled_file_path
      end
    end

    context "process response" do

      context "for an existing, unscaled image" do
        setup do
          File.expects(:exists?).with("/tmp/file/path/filename.png").returns true
          File.expects(:exists?).with("/tmp/file/path/scaled/filename-400x300-crop.png").returns false
        end

        context "with a valid HMAC" do
          setup do
            ScaleDown.expects(:valid_hmac?).returns true
            ScaleDown::Image.expects(:scale).returns true
          end

          should "scale the image" do
            ScaleDown::Scaler.process(@params)
          end

          should "return a 301 redirect to the processed image's URL" do
            assert_equal ["/file/path/scaled/filename-400x300-crop.png", 301], ScaleDown::Scaler.process(@params)
          end
        end

        context "without a valid HMAC" do
          should "return a 403 Forbidden response" do
            ScaleDown.expects(:valid_hmac?).returns false
            assert_equal 403, ScaleDown::Scaler.process(@params)[1]
          end
        end
      end

      context "for an existing, scaled, image" do
        setup do
          File.expects(:exists?).with("/tmp/file/path/filename.png").returns true
          File.expects(:exists?).with("/tmp/file/path/scaled/filename-400x300-crop.png").returns true
        end

        should "return a 301 redirect to the processed image's URL" do
          assert_equal ["/file/path/scaled/filename-400x300-crop.png", 301], ScaleDown::Scaler.process(@params)
        end
      end

      context "for a missing image" do
        setup do
          File.expects(:exists?).with("/tmp/file/path/filename.png").returns false
        end

        should "return a 404" do
          assert_equal 404, ScaleDown::Scaler.process(@params)[1]
        end
      end
    end
  end
end
