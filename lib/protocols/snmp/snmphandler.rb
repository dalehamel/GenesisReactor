require 'genesis_handler'

class SnmpHandler < GenesisHandler

  #register_protocol :echo # fixme - abstract out protocol recognition to base handler
  class << self
    alias_method :trap, :register_route
  end

end
