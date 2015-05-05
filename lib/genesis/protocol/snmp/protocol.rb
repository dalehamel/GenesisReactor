module Genesis
  module Snmp
    # Implement support for SNMP protocol using pure-ruby snmp.
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
        :snmp
      end

      # Methods to be injected into included class
      module ClassMethods
        def protocol
          Protocol.protocol
        end
      end
    end
  end
end
