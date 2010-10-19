libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'sinatra'

module ScaleDown
  require 'scale_down/version'
  require 'scale_down/controller'
  require 'scale_down/scaler'
  require 'scale_down/image'
end
