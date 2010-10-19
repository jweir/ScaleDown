class ScaleDown::Controller < Sinatra::Application

  set :raise_errors, true
  set :show_exceptions, false
  set :static, true
  set :public, "/Users/johnweir/Sites/famedriver/site/public"

  get '/' do
    "ScaleDown v 0.1"
  end

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
    ScaleDown::Scaler.process \
      :path     => params[:splat].join("/"),
      :filename => params[:filename],
      :geometry => params[:geometry],
      :hmac     => params[:hmac]
  end
end
