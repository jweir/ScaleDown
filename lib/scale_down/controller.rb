require 'cgi'

class ScaleDown::Controller < Sinatra::Application

  set :raise_errors, true
  set :show_exceptions, false
  set :static, true
  set :views, settings.root + "/templates"

  get '/' do
    # "<b>ScaleDown version #{ScaleDown::VERSION}<b/>"
    erb :index
  end

  get '/*/info' do
    info = ScaleDown::Dispatcher.info(params[:splat].join("/"))
    if info
      [200, info]
    else
      [404, "Image not found"]
    end
  end

  # get '/*/:geometry/:filename?:hmac'
  # is what I want, but this fails when the URL includes things like %23 (an encoded hash tag)
  get '/*' do
    parts = params[:splat].join("/").split("/")

    params = {
      :hmac     => request.env["QUERY_STRING"],
      :filename => CGI.unescape(parts.pop),
      :target   => parts.pop, # the label or geometry
      :splat    => parts
    }

    body, status = dispatch(params)

    ScaleDown.logger.info "Controller#get #{body} #{status}"
    $0 = "scale_down Controller#get #{body} #{status}"
    case status
    when 301 then
      # original is not a png/jpg redirect to jpg
      redirect URI.encode(body), status
    when 302 then
      # File is found or scaled, use Sinatra's built in send file method
      static!
    else
      [status, body]
    end
  end

  protected
  def dispatch(params)
    ScaleDown::Dispatcher.process \
      :path     => params[:splat].join("/"),
      :filename => params[:filename],
      :target   => params[:target],
      :hmac     => params[:hmac]
  end
end
