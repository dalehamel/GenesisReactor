require 'snmp'

require 'genesis/protocol/snmp/protocol'
require 'genesis/protocol/snmp/server'
require 'genesis/protocol/snmp/handler'

module Genesis
  # Common helper methods for protocol
  module Snmp
    # Send an SNMP trap
    def send_trap(sys_up_time, trap_oid, object_list = [], **kwargs)
      SNMP::Manager.open(host: kwargs[:host] || '127.0.0.1', trapport: kwargs[:port] || 161) do |manager|
        puts manager.trap_v2(sys_up_time, trap_oid, object_list)
      end
    end
  end
end
