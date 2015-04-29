require 'genesis_server'
require 'sinatra/base'
require 'thin'

class HttpServer < Sinatra::Base

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
  get '/foo' do
    @channel << 'foo bar'
  end
end
