require 'snmp'

require 'genesis/server'

module Genesis
  module Snmp
    # Implement an SNMP trap handling server
    class Server
      include Genesis::Server
      include Protocol

      def self.start_server
        commstr = @args[:community] || 'public'
        SNMP::TrapListener.new(host: 0, port: @port, community: commstr) do |manager|
          manager.on_trap_default do |snmp_trap|
            EM.defer do
              # FIXME: Add routing to trap handlers here
              @channel << snmp_trap
            end
          end
        end
      end
    end
  end
end
