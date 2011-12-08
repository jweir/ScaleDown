require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class ScaleDown::Image::Test < Test::Unit::TestCase

  def create(file_path, out_path, options)
    ScaleDown::Image.scale \
      :file    => file_path,
      :out     => out_path,
      :options => options
  end

  teardown do
    FileUtils.rm_r(fixture_path("scaled_test")) if File.directory?(fixture_path('scaled_test'))
  end

  context "scaling a valid image" do
    setup do
      @subject = create \
        fixture_path("files/graphic.png"),
        fixture_path("scaled_test/scaled/graphic.png"),
        { :width => 100, :height => 180}
    end

    should "save the file (and generate the path)" do
      assert File.exists?(fixture_path('scaled_test/scaled/graphic.png'))
    end

    should "scale the image" do
      image = Magick::Image.read(fixture_path("scaled_test/scaled/graphic.png")).first
      assert_equal 90, image.columns
      assert_equal 180, image.rows
    end

    should "be true" do
      assert @subject
    end
  end

  context "#geometry" do
    should "convert 'auto' to nil" do
      geo = ScaleDown::Image.geometry(:width => "auto", :height => "400")
      assert_equal 0.0, geo.width
      assert_equal 400, geo.height
    end

    should "auto scale any one dimensions" do
      assert create \
        fixture_path("files/graphic.png"),
        fixture_path("scaled_test/scaled/graphic.png"),
        { :width => "auto", :height => 150 }

      image = Magick::Image.read(fixture_path("scaled_test/scaled/graphic.png")).first
      assert_equal 150, image.rows
      assert_equal 75, image.columns
    end

    should "return nil if both dimensions are 'auto'" do
      assert_raises ScaleDown::InvalidGeometry do
        ScaleDown::Image.geometry :width => "auto", :height => "auto"
      end
    end

    should "raise an error if either dimension is outside of the ScaleDown.max_dimensions" do
      ScaleDown.max_dimensions = [1200,1200]

      assert_raises ScaleDown::InvalidGeometry do
        ScaleDown::Image.geometry :width => 1300, :height => 900
      end

      assert_raises ScaleDown::InvalidGeometry do
        ScaleDown::Image.geometry :width => 900, :height => 1300
      end
    end
  end

  context "an invalid file" do
    setup do
      @subject = create \
        fixture_path("files/invalid_jpeg.jpg"),
        fixture_path("scaled_test/scaled/graphic.jpg"),
        { :width => 100, :height => 105 }
    end

    should "return nil" do
      assert !@subject
    end

    should "not create a scaled image" do
      assert !File.exists?(fixture_path("scaled_test/scaled/graphic.jpg"))
    end
  end

  context "a file larger than the MAX_SIZE" do
    setup do
      File.expects(:size).with(fixture_path("files/graphic.png")).at_least_once.returns(50 * 1_048_576)
    end

    should "raise an exception" do
      assert_raises ScaleDown::FileSizeTooLarge do
        @subject = create \
          fixture_path("files/graphic.png"),
          fixture_path("scaled_test/scaled/graphic.png"),
          { :width => 100, :height => 105 }
      end
    end
  end

  context "cropping" do
    setup do
      @subject = create \
        fixture_path("files/graphic.png"),
        fixture_path("scaled_test/scaled/graphic.png"),
        { :width => 25, :height => 25, :crop => true }
    end

    should "crop the image to the dimensions" do
      image = Magick::Image.read(fixture_path("scaled_test/scaled/graphic.png")).first
      assert_equal 25, image.columns
      assert_equal 25, image.rows
    end
  end

  context "orientation" do
    setup do
      @subject = create \
        fixture_path("files/orient.jpg"),
        fixture_path("scaled_test/scaled/graphic.jpg"),
        { :width => "auto", :height => 800}
    end

    should "be automatic" do
      image = Magick::Image.read(fixture_path("scaled_test/scaled/graphic.jpg")).first
      assert_equal 600, image.columns
      assert_equal 800, image.rows
    end

    should "ignore files without orientation EXIF" do
      @subject = create \
        fixture_path("files/no_orient.tif"),
        fixture_path("scaled_test/scaled/graphic.jpg"),
        { :width => "auto", :height => 424}

      image = Magick::Image.read(fixture_path("scaled_test/scaled/graphic.jpg")).first
      assert_equal 330, image.columns
      assert_equal 424, image.rows
    end
  end

  context "CMYK images" do
    should "be converted to RGB" do
      create \
        fixture_path("files/cmyk.tif"),
        fixture_path("scaled_test/scaled/graphic.jpg"),
        { :width => "auto", :height => 200}

      image = Magick::Image.read(fixture_path("scaled_test/scaled/graphic.jpg")).first
      assert_equal Magick::RGBColorspace, image.colorspace
    end

    should "convert JPGs to RGB JPEGS" do
      create \
        fixture_path("files/cmyk_gray.jpg"),
        fixture_path("scaled_test/scaled/graphic_2.jpg"),
        { :width => "auto", :height => 200}

      image = Magick::Image.read(fixture_path("scaled_test/scaled/graphic_2.jpg")).first
      assert_equal Magick::RGBColorspace, image.colorspace
    end
  end

end
