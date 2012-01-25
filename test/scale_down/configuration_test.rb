require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class ScaleDown::Test < Test::Unit::TestCase

  context "Configuration" do
    context "public_folder" do
      should "set the controller's public setting" do
        ScaleDown.public_folder = "/tmp/directory"
        assert_equal "/tmp/directory", ScaleDown::Controller.public_folder
      end
    end

    context "labels" do
      context "by default" do
        should "be an empty hash" do
        end
      end

      context "when defined" do
        setup do
          ScaleDown.labels = {
            "thumbnail" => "40x40",
            "large"     => "600x600"
          }
        end

        should "return the defined hash" do
          assert_equal "40x40", ScaleDown.labels["thumbnail"]
        end
      end
    end
  end
end
