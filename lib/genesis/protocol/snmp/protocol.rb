module Genesis
  module Snmp
    # Implement support for SNMP protocol using pure-ruby snmp.
    module Protocol
      include Genesis::Protocol

      def self.start_block
        proc { Server.start_server }
      end

      def self.protocol
        :snmp
      end
    end
  end
end
