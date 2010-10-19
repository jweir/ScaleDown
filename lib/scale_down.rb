libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'sinatra'

module ScaleDown
  require 'scale_down/version'
  require 'scale_down/controller'
  require 'scale_down/scaler'
  require 'scale_down/image'

  class << self
    attr_accessor :hmac_method, :hmac_key, :hmac_length
    attr_accessor :root_path
  end

  def self.valid_hmac?(params)
    str = [params[:path], "/", params[:filename], "/", params[:geometry]].join
    hmac(str) == params[:hmac]
  end

  def self.hmac(string)
    hmac_method.new(hmac_key).update(string).to_s[0...hmac_length]
  end
end
