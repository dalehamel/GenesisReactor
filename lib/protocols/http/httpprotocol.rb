module Genesis
  module Protocol
    # Implement support for HTTP protocol
    # Levering sinatra_async, and the fact that thin uses eventmachine
    module Http
      def self.included(base)
        base.extend ClassMethods
      end

      def self.load
        require 'httpserver'
        HttpServer
      end

      def self.start_block
        proc { HttpServer.start_server }
      end

      def self.protocol
        :http
      end

      # Mehods to be injected into including class
      module ClassMethods
        def protocol
          Http.protocol
        end
      end
    end
  end
end
