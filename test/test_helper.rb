require 'lib/controller'
require 'lib/scaler'
require 'lib/image'
require 'mocha'
require 'rack/test'
require 'contest'
require 'ruby-debug'

ENV['RACK_ENV'] = 'test'

require 'forwardable'

class Test::Unit::TestCase

  def tests_path(append)
    File.join(File.expand_path(File.dirname(__FILE__)), append)
  end

end
