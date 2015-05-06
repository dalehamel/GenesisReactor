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

      def self.load_modules(module_list, mib_dir)
        mib = SNMP::MIB.new
        module_list.each { |m| mib.load_module(m, mib_dir) }
        mib
      end

      def receive_data(data)
        snmp_trap = handle_trap(data)
        @channel << snmp_trap
        route_trap(snmp_trap)
      end

      private

      def handle_trap(data)
        source_port, source_ip = Socket.unpack_sockaddr_in(get_peername)

        message = SNMP::Message.decode(data, @mib)
        snmp_trap = message.pdu

        # If we configured a community and the message wasn't from our community, bail
        close_connection if @community != '' && @community != message.community

        # Handle inform requests, which want a response
        handle_inform(snmp_trap, message, source_ip, source_port)

        # Append source ip and return
        snmp_trap.source_ip = source_ip
        snmp_trap
      end

      def handle_inform(snmp_trap, message, source_ip, source_port)
        return unless snmp_trap.is_a?(SNMP::InformRequest)
        UDPSocket.new.send(message.response.encode, 0, source_ip, source_port)
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
    end
  end
end
