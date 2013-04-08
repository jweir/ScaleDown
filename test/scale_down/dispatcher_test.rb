require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class ScaleDown::Dispatcher::Test < Test::Unit::TestCase

  context "Dispatcher::Test" do
    setup do
      ScaleDown.hmac_key    = "secret"
      ScaleDown.hmac_method = HMAC::SHA1
      ScaleDown.hmac_length = 8
      ScaleDown.public_folder = "/tmp"

      hmac = HMAC::SHA1.new("secret").update("file/path/400x300-crop/filename.png").to_s

      @params = {
        :path     => "file/path/scaled",
        :filename => "filename.png",
        :target   => "400x300-crop",
        :hmac     => hmac[0...8]
      }
    end

    context "instance" do
      setup do
        @dispatcher = ScaleDown::Dispatcher.new @params
      end

      should "validate the HMAC" do
        ScaleDown.expects(:valid_hmac?).with(@params).returns true
        assert @dispatcher.valid_hmac?
      end

      should "determine root file existance" do
        File.expects(:exists?).with("/tmp/file/path/filename.png").returns true
        assert @dispatcher.root_file_exists?
      end

      should "determine the scaled image's existance" do
        File.expects(:exists?).with("/tmp/file/path/scaled/400x300-crop/filename.png").returns true
        assert @dispatcher.scaled_file_exists?
      end

      should "parse the geometry params into options" do
        assert_equal({:width => 400, :height => 300, :crop => true}, @dispatcher.image_options)
      end

      should "have a redirect path" do
        assert_equal "/file/path/scaled/400x300-crop/filename.png", @dispatcher.redirect_path
      end

      should "process the image" do
        ScaleDown::Image.expects(:scale).with(
          :file    => @dispatcher.root_path,
          :out     => @dispatcher.scaled_file_path,
          :options => @dispatcher.image_options).returns true

          assert @dispatcher.scale
      end

      should "default to a jpg out file" do
        ["jpg", "tga", "tif", "pdf", "psd"].each do |ext|
          dispatcher = ScaleDown::Dispatcher.new @params.merge(:filename => "test.#{ext}")
          assert_match /\.jpg$/, dispatcher.scaled_file_path
        end
      end

      should "use a png for png graphics" do
        dispatcher = ScaleDown::Dispatcher.new @params.merge(:filename => "test.png")
        assert_match /\.png$/, dispatcher.scaled_file_path
      end

      should "use a jpeg for all non png images" do
        dispatcher = ScaleDown::Dispatcher.new @params.merge(:filename => "test.tif")
        assert_match /\.jpg$/, dispatcher.scaled_file_path
        assert_match /\.jpg$/, dispatcher.redirect_path
      end

      context "redirect_code" do
        should "be 302 for png and jpgs" do
          dispatcher = ScaleDown::Dispatcher.new @params
          assert_equal 302, dispatcher.redirect_code
        end

        should "be 301 for non png or jpgs " do
          dispatcher = ScaleDown::Dispatcher.new @params.merge(:filename => "test.tif")
          assert_equal 301, dispatcher.redirect_code
        end
      end
    end

    context "target" do
      context "from a label" do
        setup do
          ScaleDown.labels = { "thumbnail" => "40x50" }
          @subject = ScaleDown::Dispatcher.new :target => "thumbnail"
        end

        should "use the label's width and height" do
          dim = @subject.image_options
          assert_equal 40, dim[:width]
          assert_equal 50, dim[:height]
          assert_equal false, dim[:crop]
        end

        should "always valid the hmac" do
          assert @subject.valid_hmac?
        end

        should "work with the cropped flag" do
          @subject = ScaleDown::Dispatcher.new :target => "thumbnail-crop"
          dim = @subject.image_options
          assert_equal 40, dim[:width]
          assert_equal 50, dim[:height]
          assert_equal true, dim[:crop]
        end
      end
    end

    context "process response" do
      context "for an existing, unscaled image" do
        setup do
          File.expects(:exists?).with("/tmp/file/path/filename.png").returns true
          File.expects(:exists?).with("/tmp/file/path/scaled/400x300-crop/filename.png").returns false
        end

        context "with a valid HMAC" do
          setup do
            ScaleDown.expects(:valid_hmac?).returns true
            ScaleDown::Image.expects(:scale).returns true
          end

          should "scale the image" do
            ScaleDown::Dispatcher.process(@params)
          end

          should "return a 302 redirect to the processed image's URL" do
            assert_equal ["/file/path/scaled/400x300-crop/filename.png", 302], ScaleDown::Dispatcher.process(@params)
          end
        end

        context "without a valid HMAC" do
          should "return a 403 Forbidden response" do
            ScaleDown.expects(:valid_hmac?).returns false
            assert_equal 403, ScaleDown::Dispatcher.process(@params)[1]
          end
        end
      end

      context "for an existing, scaled, image" do
        setup do
          File.expects(:exists?).with("/tmp/file/path/filename.png").returns true
          File.expects(:exists?).with("/tmp/file/path/scaled/400x300-crop/filename.png").returns true
        end

        should "return a 302 redirect to the processed image's URL" do
          assert_equal ["/file/path/scaled/400x300-crop/filename.png", 302], ScaleDown::Dispatcher.process(@params)
        end
      end

      context "for a missing image" do
        setup do
          File.expects(:exists?).with("/tmp/file/path/filename.png").returns false
        end

        should "return a 404" do
          assert_equal 404, ScaleDown::Dispatcher.process(@params)[1]
        end
      end
    end
  end
end
