require 'eventmachine'
require 'snmp'

require 'genesis_server'
require 'snmpprotocol'

# Implement an SNMP trap handling server
class SnmpServer
  include GenesisServer
  include SnmpProtocol

  def self.start_server
    commstr = @args[:community] || 'public'
    SNMP::TrapListener.new(host: 0, port: @port, community: commstr) do |manager|
      manager.on_trap_default do |snmp_trap|
        EM.defer do
          # Add routes here
          # Also put into channel
          # Test handler for channel
          puts snmp_trap
          @channel << snmp_trap
          puts 'trapped'
        end
      end
    end
  end
end

# To test:
# SNMP::Manager.open(Host: '127.0.0.1', TrapPort: 1061) do |manager|
#   puts manager.trap_v2(1234, "1.3.6.1.2.3.4", ["1.2.3", "1.4.5.6"])
# end
