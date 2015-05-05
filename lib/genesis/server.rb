require 'eventmachine'

module Genesis
  # Abstract base class for all servers
  module Server
    attr_accessor :handle_routes, :channel

    def self.included(base)
      base.extend ClassMethods
    end

    # Methods to be injected onto the class
    module ClassMethods
      def start(port, routes, **kwargs, &block)
        @port = port
        @handle_routes = routes || []
        @channel = kwargs[:channel]
        @args = kwargs

        # Allow a custom, non EM, server to be run
        if block_given? && block
          yield
        else
          default_start
        end
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
end
