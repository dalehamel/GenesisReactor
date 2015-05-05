require 'genesis/handler'

module Genesis
  module Snmp
    # Implement a handler for SNMP traps
    class Handler < Genesis::Handler
      include Protocol

      class << self
        alias_method :trap, :register_route
      end
    end
  end
end
