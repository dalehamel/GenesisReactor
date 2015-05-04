module Genesis
  # Interface for a GenesisAgent
  # Allows subclasess specifying agents in a DSL
  class Agent
    class << self
      attr_accessor :agents
      def register_agent(**kwargs, &block)
        @agents << { interval: kwargs[:interval] || 60, opts: kwargs, block: block }
      end

      def reset!
        @agents = []
      end

      def inherited(subclass)
        subclass.reset!
        super
      end

      alias_method :schedule, :register_agent
    end

    reset!
  end
end
