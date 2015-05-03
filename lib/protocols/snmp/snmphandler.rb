require 'genesis_handler'
require 'snmpprotocol'

# Implement a handler for SNMP traps
class SnmpHandler < GenesisHandler
  include SnmpProtocol

  class << self
    alias_method :trap, :register_route
  end
end
