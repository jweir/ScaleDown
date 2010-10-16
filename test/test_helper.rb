require 'lib/scale_down'
require 'rack/test'
require 'contest'
require 'mocha'
require 'ruby-debug'

ENV['RACK_ENV'] = 'test'

require 'forwardable'

class Test::Unit::TestCase

  def hmac(path, secret)
    hmac = HMAC::MD5.new(secret).update(path).to_s
  end

  def tests_path(append)
    File.join(File.expand_path(File.dirname(__FILE__)), append)
  end

end
