require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class Image::Test < Test::Unit::TestCase

  def create(file_path, out_path, options)
    Image.scale \
      :file    => file_path,
      :out     => out_path,
      :options => options
  end

  teardown do
    FileUtils.rm_r(tests_path("scaled_test")) if File.directory?(tests_path('scaled_test'))
  end

  context "scaling a valid image" do
    setup do
      @subject = create \
        tests_path("files/graphic.png"),
        tests_path("scaled_test/graphic_scaled.png"),
        { :width => 100, :height => 180}
    end

    should "save the file (and generate the path)" do
      assert File.exists?(tests_path('scaled_test/graphic_scaled.png'))
    end

    should "scale the image" do
      image = Magick::Image.read(tests_path("scaled_test/graphic_scaled.png")).first
      assert_equal 90, image.columns
      assert_equal 180, image.rows
    end

    should "be true" do
      assert @subject
    end
  end

  context "#geometry" do
    should "convert 'auto' to nil" do
      geo = Image.geometry(:width => "auto", :height => "400")
      assert_equal 0.0, geo.width
      assert_equal 400, geo.height
    end

    should "auto scale" do
      assert create \
        tests_path("files/graphic.png"),
        tests_path("scaled_test/graphic_scaled.png"),
        { :width => "auto", :height => 150 }

      image = Magick::Image.read(tests_path("scaled_test/graphic_scaled.png")).first
      assert_equal 150, image.rows
      assert_equal 75, image.columns
    end
  end

  context "an invalid file" do
    setup do
      @subject = create \
        tests_path("files/invalid_jpeg.jpg"),
        tests_path("scaled_test/graphic_scaled.jpg"),
        { :width => 100, :height => 105 }
    end

    should "return nil" do
      assert !@subject
    end

    should "not create a scaled image" do
      assert !File.exists?(tests_path("scaled_test/graphic_scaled.jpg"))
    end
  end

  context "cropping" do
    setup do
      @subject = create \
        tests_path("files/graphic.png"),
        tests_path("scaled_test/graphic_scaled.png"),
        { :width => 25, :height => 25, :crop => true }
    end

    should "crop the image to the dimensions" do
      image = Magick::Image.read(tests_path("scaled_test/graphic_scaled.png")).first
      assert_equal 25, image.columns
      assert_equal 25, image.rows
    end
  end

  context "orientation" do
    setup do
      @subject = create \
        tests_path("files/orient.jpg"),
        tests_path("scaled_test/graphic_scaled.jpg"),
        { :width => "auto", :height => 800}
    end

    should "be automatic" do
      image = Magick::Image.read(tests_path("scaled_test/graphic_scaled.jpg")).first
      assert_equal 600, image.columns
      assert_equal 800, image.rows
    end
  end

  context "color correction" do
    setup do
      @subject = create \
        tests_path("files/cmyk.tif"),
        tests_path("scaled_test/graphic_scaled.jpg"),
        { :width => "auto", :height => 200}
    end

    should "be automatic" do
      image = Magick::Image.read(tests_path("scaled_test/graphic_scaled.jpg")).first
      assert_equal Magick::RGBColorspace, image.colorspace
    end
  end

end
