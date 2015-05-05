require 'genesis/agent'

module Genesis
  module Snmp
    # Define an agent for Snmp protocol
    class Agent < Genesis::Agent
      include Protocol
    end
  end
end
