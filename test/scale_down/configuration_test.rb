require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class ScaleDown::Test < Test::Unit::TestCase

  context "Configuration" do
    context "public_folder" do
      should "set the controller's public setting" do
        ScaleDown.public_folder = "/tmp/directory"
        assert_equal "/tmp/directory", ScaleDown::Controller.public_folder
      end
    end
  end
end
