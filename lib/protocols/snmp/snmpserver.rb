require 'eventmachine'
require 'snmp'
require 'genesis_server'


class SnmpServer
  include GenesisServer


  def self.start_server
    commstr = @args[:community] || 'public'
    m = SNMP::TrapListener.new(Port: @port, Community: commstr) do |manager|
#Port: @port,
      manager.on_trap_default do |trap|
        EM.defer do
          # Add routes hereA
          # Also put into channel
          # Test handler for channel
          puts 'trapped'
          sleep 50
          p trap
        end
      end
    end
  end
end

# To test:
#SNMP::Manager.open(Host: '127.0.0.1', TrapPort: 1061) do |manager|
#  puts manager.trap_v2(1234, "1.3.6.1.2.3.4", ["1.2.3", "1.4.5.6"])
#end

