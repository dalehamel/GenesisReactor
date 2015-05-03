class GenesisHandler
  class << self
    attr_accessor :routes, :subscribers
    def register_route(match, opts={}, &block)
      @routes[match] = {verb: __callee__.to_s, opts: opts, block: block}
    end

    def register_subscriber(*args, &block)
      @subscribers << { block: block}
    end

    def reset!
      @subscribers = []
      @routes = {}
    end

    def inherited(subclass)
      subclass.reset!
      super
    end

    alias_method :subscribe, :register_subscriber
  end

  reset!
end
