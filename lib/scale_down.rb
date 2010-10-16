libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'bundler/setup'
require 'sinatra'

module ScaleDown
  require 'scale_down/controller'
  require 'scale_down/scaler'
  require 'scale_down/image'
end
