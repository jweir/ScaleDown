require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class ScaleDown::Info::Test < Test::Unit::TestCase
  context "#new" do
    setup do
      ScaleDown.public_folder = File.join(File.expand_path(File.dirname(__FILE__)), "..")
    end

    should "be missing? a non-existant image" do
      assert ScaleDown::Info.new("files/notthere.jpg").missing?
    end

    should "generate json" do
      info = ScaleDown::Info.new("files/graphic.png")
      assert info.to_json
    end
  end

  context "properties" do
    should "have dimentions" do
      info = ScaleDown::Info.new("files/graphic.png")
      assert_equal 200, info.hash[:width]
      assert_equal 400, info.hash[:height]
    end

    should "set the animation flag for animated gifs" do
      info = ScaleDown::Info.new("files/graphic.png")
      assert_equal false, info.hash[:animated]

      info = ScaleDown::Info.new("files/animated.gif")
      assert_equal true, info.hash[:animated]
    end
  end
end
