class GenesisHandler
  class << self
    attr_accessor :routes, :handlers
    def register_route(match, opts={}, &block)
      @routes ||= {}
      @routes[match] = {verb: __callee__.to_s, opts: opts, block: block}
    end

    def register_handler(*args, &block)
      @handlers ||= []
      @handlers << { block: block}
    end

    def reset!
      @handlers = []
      @routes = {}
    end

    alias_method :handle, :register_handler
  end
end
