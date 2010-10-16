require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'lib/scaler'

class Controller < Sinatra::Application

  set :raise_errors, true
  set :show_exceptions, false

  get '/*/:filename/:geometry/:hmac' do
    path, status = scaler(params) 
    unless status == 403
      redirect path, status
    else
      [status, "Error: this image could not be processed"]
    end
  end

  protected
  def scaler(params)
    Scaler.request \
      :path     => params[:splat].join("/"),
      :filename => params[:filename],
      :geometry => params[:geometry],
      :hmac     => params[:hmac]
  end
end
