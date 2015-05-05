module Genesis
  module Echo
    # Implement a simple protocol to demonstrate
    # how to write a protocol, and facilitate testing.
    # In keeping with event machine tradition, it's a simple 'echo' protocol.
    module Protocol
      def self.included(base)
        base.extend ClassMethods
      end

      def self.load
        require 'echoserver'
        Server
      end

      def self.start_block
      end

      def self.protocol
        :echo
      end

      # Methods to inject into included class
      module ClassMethods
        def protocol
          Protocol.protocol
        end
      end
    end
  end
end
