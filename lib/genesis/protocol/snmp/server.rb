require 'snmp'
require 'socket'

require 'genesis/server'

module Genesis
  module Snmp
    # Implement an SNMP trap handling server
    # Using SNMP::TrapListener as a prototype
    # But, leverage event machine for it's non-blocking threadpool
    # TODO: Upstream these changes
    class Server < EM::Connection
      include Genesis::Server
      include Protocol

      attr_accessor :mib

      def self.start_server
        commstr = @args[:community] || 'public'
        mib_dir = @args[:mib_dir] || SNMP::MIB::DEFAULT_MIB_PATH
        mib_mods = @args[:mib_mods] || SNMP::Options.default_modules
        mib = load_modules(mib_mods, mib_dir)
        EM.open_datagram_socket('0.0.0.0', @port, self) do |conn|
          conn.mib = mib
          conn.channel = @channel
          conn.handle_routes = @handle_routes
        end

#        SNMP::TrapListener.new(host: '0.0.0.0', port: @port, community: commstr) do |manager|
#          manager.on_trap_default do |snmp_trap|
#            EM.defer do
#              @channel << snmp_trap
#              route_trap(snmp_trap)
#            end
#          end
#        end
      end

      def receive_data(data)
        source_port, source_ip = Socket.unpack_sockaddr_in(get_peername)

        message = SNMP::Message.decode(data, @mib)
        # FIXME: check community
        snmp_trap = message.pdu

        if snmp_trap.kind_of?(SNMP::InformRequest)
          UDPSocket.new.send(message.response.encode, 0, source_ip, source_port)
        end

        snmp_trap.source_ip = source_ip
        @channel << snmp_trap
        route_trap(snmp_trap)
      end

      def route_trap(snmp_trap)
        @handle_routes.each do |verb, matchdata|
          case verb
          when 'trap'
            route_trap_handler(snmp_trap, matchdata)
          end
        end
      end

      def route_trap_handler(snmp_trap, matchdata)
        trap_oid = snmp_trap.trap_oid.join('.')
        matchdata.each do |oid, blockdata|
          blockdata[:block].call(snmp_trap) if  oid =~ /#{trap_oid}/
        end
      end

      private

      def self.load_modules(module_list, mib_dir)
        mib = SNMP::MIB.new
        module_list.each { |m| mib.load_module(m, mib_dir) }
        mib
      end
    end
  end
end
