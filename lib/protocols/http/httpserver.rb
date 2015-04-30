require 'genesis_server'
require 'sinatra/async'
require 'thin'


class HttpServer < Sinatra::Base

  register Sinatra::Async
  # FIXME - need a way to refactor this somehow to share with GenesisServer
  def self.start(port, routes)

    channel = EM::Channel.new
    app = self.new(channel:channel)

    dispatch = Rack::Builder.app do
      map '/' do
        run app
      end
    end

    r = Rack::Server.start({
      app:    dispatch,
      server: 'thin',
      Host:   '0.0.0.0',
      Port:   port,
    })

    return channel
  end

  def initialize(app = nil, **kwargs)
    super(app)
    @channel = kwargs[:channel] || nil
  end

  # FIXME: need a way to define routes in handler class...
  # Idea: create a helper that accepts the method (verb - get, etc), the args, and the block - then just call it.
  # eg;  post(path, opts = {}, &bk) from sinatra.rb
  # def register_route
  #   send(:verb, opts, &block)
  # end
  # we'll want to transparently translate them to their async versions
  aget '/foo' do
    @channel << 'foo'
    body 'foo'
  end

  aget '/bar' do
    @channel << 'bar'
    sleep 5
    body 'bar'
  end

  helpers do
    # Enable partial template rendering
    def partial (template, locals = {})
      erb(template, :layout => false, :locals => locals)
    end

    # Define our asynchronous scheduling mechanism, could be anything
    # Chose EM.defer for simplicity
    # This powers our asynchronous requests, and keeps us from blocking the main thread.
    def native_async_schedule(&b)
      EM.defer(&b)
    end

    # Needed to properly catch exceptions in async threads
    def handle_exception!(context)
      if context.message == "Sinatra::NotFound"
        error_msg = "Resource #{request.path} does not exist"
        puts error_msg
        ahalt(404, error_msg)
      else
        puts context.message
        puts context.backtrace.join("\n")
        ahalt(500,"Uncaught exception occurred")
      end
    end
  end

end
