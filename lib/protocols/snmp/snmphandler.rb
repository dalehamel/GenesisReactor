require 'genesis/handler'
require 'snmpprotocol'

# Implement a handler for SNMP traps
class SnmpHandler < Genesis::Handler
  include SnmpProtocol

  class << self
    alias_method :trap, :register_route
  end
end
