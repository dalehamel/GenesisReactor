require 'genesis_handler'
require 'snmpprotocol'

class SnmpHandler < GenesisHandler

  include SnmpProtocol

  class << self
    alias_method :trap, :register_route
  end

end
