require 'genesis_server'
require 'sinatra/async'
require 'thin'


class HttpServer < Sinatra::Base

  register Sinatra::Async
  # FIXME - need a way to refactor this somehow to share with GenesisServer
  def self.start(port, routes)

    channel = EM::Channel.new
    app = self.new(channel:channel, routes:routes['http'])

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
    @extended_routes = kwargs[:routes] || {}
    initialize_routes

  end

private
  def initialize_routes

    if routes = @extended_routes
      routes.each do |verb, matches|
        matches.each do |match, data|
          register_route(verb, match, data[:args], data[:block])
        end
      end
    end
  end

  def register_route(verb, match, opts, block)
    async_verb = "a#{verb}"
    verb = async_verb if self.class.respond_to? async_verb
    puts verb
    self.class.send(verb, match, opts, &block)
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
