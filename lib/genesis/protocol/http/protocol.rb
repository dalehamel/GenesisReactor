module Genesis
  module Http
    # Implement support for HTTP protocol
    # Levering sinatra_async, and the fact that thin uses eventmachine
    module Protocol
      def self.included(base)
        base.extend ClassMethods
      end

      def self.load
        Server
      end

      def self.start_block
        proc { Server.start_server }
      end

      def self.protocol
        :http
      end

      # Mehods to be injected into including class
      module ClassMethods
        def protocol
          Protocol.protocol
        end
      end
    end
  end
end
