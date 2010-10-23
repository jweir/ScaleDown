require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class ScaleDown::Test < Test::Unit::TestCase

  context "Configuration" do
    context "public_path" do
      should "set the controller's public setting" do
        ScaleDown.public_path = "/tmp/directory"
        assert_equal "/tmp/directory", ScaleDown::Controller.public
      end
    end
  end
end
