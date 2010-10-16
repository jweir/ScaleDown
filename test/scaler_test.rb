require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class Scaler::Test < Test::Unit::TestCase

  # context "parsing a request" do

    # should "have an image path" do
      # Scaler.expects(:request).with(
        # :path     => "user/path",
        # :filename => "filename.png",
        # :geometry => "400x300-cropped-grayscale",
        # :hmac     => "HMAC").
      # returns ["path","status"]

    # end
  # end

	setup do
		Scaler.hmac_key    = "secret"
		Scaler.hmac_method = HMAC::MD5
		Scaler.hmac_length = 8
		Scaler.root_path   = "/tmp"

		hmac = HMAC::MD5.new("secret").update("file/pathfilename.png400x300-crop-grayscale").to_s

		@params = {
			:path     => "file/path",
			:filename => "filename.png",
			:geometry => "400x300-crop-grayscale",
      :hmac     => hmac[0...8]
		}
	end

	context "HMAC" do
		should "validate when the params match the HMAC signature" do
			assert Scaler.valid_hmac?(@params)
		end

		should "not validate when the params do not match the HMAC signature" do
			assert !Scaler.valid_hmac?(@params.merge(:path => "file/different"))
	  end
	end

	context "instance" do
		setup do
			@scaler = Scaler.new @params
		end

		should "validate the HMAC" do
      Scaler.expects(:valid_hmac?).with(@params).returns true
			assert @scaler.valid_hmac?
		end

		should "determine root file existance" do
			File.expects(:exists?).with("/tmp/file/path/filename.png").returns true
			assert @scaler.root_file_exists?
		end

	  should "deterimine the scaled image's existance" do
			File.expects(:exists?).with("/tmp/file/path/scaled/filename-400x300-crop-grayscale.png").returns true
		  assert @scaler.scaled_file_exists?
		end

		should "parse the geometry params into options" do
			assert_equal({:width => 400, :height => 300, :crop => true, :grayscale => true}, @scaler.image_options)
		end

		should "have a redirect path" do
			assert_equal "file/path/scaled/filename-400x300-crop-grayscale.png", @scaler.redirect_path
		end

		should "process the image" do
			Image.expects(:scale).with(
				:file    => @scaler.root_path,
				:out     => @scaler.scaled_file_path,
				:options => @scaler.image_options).returns true

			assert @scaler.scale
		end
	end

	context "request response" do

		setup do
			Scaler.hmac_key    = "secret"
			Scaler.hmac_method = HMAC::MD5
			Scaler.hmac_length = 8
			Scaler.root_path   = "/tmp"

			hmac = HMAC::MD5.new("secret").update("pathfilename.png40x30").to_s

			@params = {
				:path     => "path",
				:filename => "filename.png",
				:geometry => "40x30",
				:hmac     => hmac[0...8]
			}
		end
		context "for an existing, unscaled image" do
			setup do
				File.expects(:exists?).with("/tmp/path/filename.png").returns true
				File.expects(:exists?).with("/tmp/path/scaled/filename-40x30.png").returns false
			end

			context "with a valid HMAC" do
				should "scale the image" do
					Image.expects(:scale).returns true
					Scaler.request(@params)
				end

				should "return a 301 redirect to the processed image's URL" do
					assert_equal ["path/scaled/filename-40x30.png", 301], Scaler.request(@params)
				end
			end

			context "without a valid HMAC" do
				should "return a 403 Forbidden response" do
					Scaler.expects(:valid_hmac?).returns false
					assert_equal 403, Scaler.request(@params)[1]
				end
			end
		end

		context "for an existing, scaled, image" do
			setup do
				File.expects(:exists?).with("/tmp/path/filename.png").returns true
				File.expects(:exists?).with("/tmp/path/scaled/filename-40x30.png").returns true
			end

			should "return a 301 redirect to the processed image's URL" do
				assert_equal ["path/scaled/filename-40x30.png", 301], Scaler.request(@params)
			end
		end

		context "for a missing image" do
			setup do
				File.expects(:exists?).with("/tmp/path/filename.png").returns false
			end

			should "return a 404" do
				assert_equal 404, Scaler.request(@params)[1]
			end
		end
	end
end

