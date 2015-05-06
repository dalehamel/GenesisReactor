require 'snmp'
require 'socket'

require 'genesis/server'

module Genesis
  module Snmp
    # Implement an SNMP trap handling server
    class Server < EM::Connection
      include Genesis::Server
      include Protocol

      attr_accessor :mib, :community

      def self.start_server
        commstr = @args[:community] || ''
        mib_dir = @args[:mib_dir] || SNMP::MIB::DEFAULT_MIB_PATH
        mib_mods = @args[:mib_mods] || SNMP::Options.default_modules
        mib = load_modules(mib_mods, mib_dir)
        EM.open_datagram_socket('0.0.0.0', @port, self) do |conn|
          conn.mib = mib
          conn.community = commstr
          conn.channel = @channel
          conn.handle_routes = @handle_routes
        end
      end

      def receive_data(data)
        source_port, source_ip = Socket.unpack_sockaddr_in(get_peername)

        message = SNMP::Message.decode(data, @mib)
        close_connection if @community != '' && @community != message.community
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
