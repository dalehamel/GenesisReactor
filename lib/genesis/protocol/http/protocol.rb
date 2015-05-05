module Genesis
  module Http
    # Implement support for HTTP protocol
    # Levering sinatra_async, and the fact that thin uses eventmachine
    module Protocol
      include Genesis::Protocol

      def self.start_block
        proc { Server.start_server }
      end

      def self.protocol
        :http
      end
    end
  end
end
