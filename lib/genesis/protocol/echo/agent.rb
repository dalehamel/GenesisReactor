require 'genesis/agent'

module Genesis
  module Echo
    # Define an agent for Echo protocol
    class Agent < Genesis::Agent
      include Protocol
    end
  end
end
