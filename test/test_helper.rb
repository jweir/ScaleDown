require './lib/scale_down'
require 'rack/test'
require 'contest'
require 'mocha'

ENV['RACK_ENV'] = 'test'

require 'forwardable'

class Test::Unit::TestCase

  def hmac(path, secret)
    hmac = HMAC::SHA1.new(secret).update(path).to_s
  end

  def fixture_path(append)
    File.join(File.expand_path(File.dirname(__FILE__)), append)
  end

end
