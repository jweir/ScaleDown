class ScaleDown::Controller < Sinatra::Application

  set :raise_errors, true
  set :show_exceptions, false
  set :static, true

  get '/' do
    "<b>ScaleDown version #{ScaleDown::VERSION}<b/>"
  end

  get '/*/info' do
    info = ScaleDown::Scaler.info(params[:splat].join("/"))
    if info
      [200, info]
    else
      [404, "Image not found"]
    end
  end

  # get '/*/:filename/:geometry/:hmac'
  # is what I want, but this fails when the URL includes things like %23 (an encoded hash tag)
  get '/*' do
    parts = params[:splat].join("/").split("/")

    params = {
      :hmac     => parts.pop,
      :geometry => parts.pop,
      :filename => parts.pop,
      :splat    => parts
    }
    path, status = scaler(params)

    # TODO Eh? Shouldn't it be if 301
    unless status == 403
      redirect URI.encode(path), status
    else
      # TODO error messages which explain what went wrong
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
