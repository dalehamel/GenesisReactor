require 'sinatra/async'
require 'tilt/erb'
require 'thin'

require 'genesis/server'
require 'async_monkeypatch'

module Genesis
  module Http
    # Implement an HTTP server using async_sinatra and thin
    class Server < Sinatra::Base
      include Genesis::Server
      include Protocol
      register Sinatra::Async

      # Block to actually start the server
      def self.start_server
        app = new(channel: @channel, routes: @handle_routes, views: @args[:views] || [])
        dispatch = Rack::Builder.app do
          map '/' do
            run app
          end
        end

        # Enable full request logging with @debug
        Thin::Logging.trace=true if @args[:debug]
        # Since Thin is backed by EventMachine's TCPserver anyways,
        # This is just a TCPServer like any other - running inside the same EventMachine!
        Thin::Server.new(@port, '0.0.0.0', dispatch).backend.start
      end

      # Inject the channel and extended routes
      def initialize(app = nil, **kwargs)
        super(app)
        @channel = kwargs[:channel] || nil
        @extended_routes = kwargs[:routes] || {}
        @views = kwargs[:views] || []
        initialize_routes
      end

      private

      # Register all routes provided
      def initialize_routes
        @extended_routes.each do |verb, matches|
          matches.each do |match, data|
            register_route(verb, match, data[:args], data[:block])
          end
        end
      end

      # Injects a route into the sinatra class
      def register_route(verb, match, opts, block)
        async_verb = "a#{verb}" # force verb to async verb
        self.class.send(async_verb, match, opts, &block)
      end

      helpers do
        # Enable partial template rendering
        def partial(template, locals = {})
          erb(template, layout: false, locals: locals)
        end

        # Override template search directorys to add spells
        def find_template(views, *a, &block)
          Array(@views).each { |v| super(v, *a, &block) }
        end

        # Define our asynchronous scheduling mechanism, could be anything
        # Chose EM.defer for simplicity
        # This powers our asynchronous requests, and keeps us from blocking the main thread.
        def native_async_schedule(&b)
          EM.defer(&b)
        end

        # Needed to properly catch exceptions in async threads
        def handle_exception!(context)
          if context.message == 'Sinatra::NotFound'
            error_msg = "Resource #{request.path} does not exist"
            puts error_msg
            ahalt(404, error_msg)
          else
            puts context.message
            puts context.backtrace.join("\n")
            ahalt(500, 'Uncaught exception occurred')
          end
        end
      end
    end
  end
end
