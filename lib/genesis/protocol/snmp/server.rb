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
              @channel << snmp_trap
              route_trap(snmp_trap)
            end
          end
        end
      end

      def self.route_trap(snmp_trap)
        @handle_routes.each do |verb, matchdata|
          case verb
          when 'trap'
            route_trap_handler(snmp_trap, matchdata)
          end
        end
      end

      def self.route_trap_handler(snmp_trap, matchdata)
        trap_oid = snmp_trap.trap_oid.join('.')
        matchdata.each do |oid, blockdata|
          blockdata[:block].call(snmp_trap) if  oid =~ /#{trap_oid}/
        end
      end
    end
  end
end
