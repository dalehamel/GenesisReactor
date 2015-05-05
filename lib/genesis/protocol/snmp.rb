require 'snmp'

require 'genesis/protocol/snmp/protocol'
require 'genesis/protocol/snmp/server'
require 'genesis/protocol/snmp/handler'
require 'genesis/protocol/snmp/agent'

module Genesis
  # Common helper methods for protocol
  module Snmp
    # Send an SNMP trap, returns the length of the trap message sent
    def self.send_trap(sys_up_time, trap_oid, object_list = [], **kwargs)
      manager(kwargs) do |mgr|
        return mgr.trap_v2(sys_up_time, trap_oid, object_list)
      end
    end

    # Send an SNMP get request
    def self.get(oids = [], **kwargs)
      manager(kwargs) do |mgr|
        mgr.get(oids)
      end
    end

    # FIXME: implement - these are tricky to test without an actual SNMP server
    # # Send an SNMP set request
    # def self.set(bindings = {}, **kwargs)
    #   manager(kwargs) do |mgr|
    #     bindings.each do |oid, value|
    #       mgr.set(SNMP::VarBind.new(oid, value)) # FIXME maybe try and infer type for varbind from value's type to avoid leaky abstraction?
    #     end
    #   end
    # end

    # # Walk an OID table rooted at any oids provided
    # def self.get(oids = [], **kwargs)
    #   manager(kwargs) do |mgr|
    #     mgr.walk(oids)
    #   end
    # end

    private

    # Create a manager and yield it to perform the request
    def self.manager(args)
      host = args[:host] || '127.0.0.1'
      port = args[:port] || 161
      trapport = args[:trapport] || 162
      community = args[:community] || 'public'
      SNMP::Manager.open(Host: host, Port: port, TrapPort: trapport, Community: community) do |mgr|
        yield mgr
      end
    end
  end
end
