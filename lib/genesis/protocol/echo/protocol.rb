require 'genesis/protocol'

module Genesis
  module Echo
    # Implement a simple protocol to demonstrate
    # how to write a protocol, and facilitate testing.
    # In keeping with event machine tradition, it's a simple 'echo' protocol.
    module Protocol
      include Genesis::Protocol

      def self.protocol
        :echo
      end
    end
  end
end
