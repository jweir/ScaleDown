libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'sinatra'
require 'RMagick'
require 'mini_magick'
require 'hmac-sha1'

module ScaleDown
  require 'scale_down/configuration'
  require 'scale_down/version'
  require 'scale_down/controller'
  require 'scale_down/dispatcher'
  require 'scale_down/image'

  class InvalidGeometry < Exception; end
  class FileSizeTooLarge < Exception; end


  def self.valid_hmac?(params)
    str = ["/", params[:geometry], "/",params[:path], "/", params[:filename]].join
    hmac(str) == params[:hmac]
  end

  def self.hmac(string)
    hmac_method.new(hmac_key).update(string).to_s[0...hmac_length]
  end
end
