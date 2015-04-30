class GenesisHandler
  def initialize(genesis)
    @genesis = genesis
    (self.class.routes || {}).each do |match, data|
      route(match, data[:verb], data[:opts], data[:block])
    end
    (self.class.handlers || []).each do |handler|
      handle { handler[:block].call }
    end
  end

  # Register handler
  def handle(&block)
    @genesis.register_handler(self.class.protocol, block)
  end

  # Register route
  def route(match, verb, opts={}, block)
    @genesis.register_route(self.class.protocol, verb, match, opts, block)
  end

  class << self
    attr_accessor :routes, :handlers, :protocol

    def register_route(match, opts={}, &block)
      @routes ||= {}
      @routes[match] = {verb: __callee__.to_s, opts: opts, block: block}
    end

    def register_handler(*args, &block)
      @handlers ||= []
      @handlers << { block: block}
    end

    def register_protocol(protocol)
      @protocol = protocol.to_s
    end
    alias_method :handle, :register_handler
  end

end


