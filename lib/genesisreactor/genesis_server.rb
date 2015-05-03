require 'eventmachine'

# Abstract base class for all servers
module GenesisServer
  attr_accessor :handle_routes, :channel

  def self.included(base)
    base.extend ClassMethods
  end

  # Methods to be injected onto the class
  module ClassMethods
    def start(port, routes, **kwargs)
      @port = port
      @handle_routes = routes || []
      @channel = EM::Channel.new
      @args = kwargs

      # Allow a custom, non EM, server to be run
      if block_given?
        yield
      else
        default_start
      end
      @channel
    end

    private

    def default_start
      # But default to an EM server if nothing else is provided
      EM.start_server '0.0.0.0', @port, self do |conn|
        conn.channel = @channel
        conn.handle_routes = @handle_routes
      end
    end
  end
end
