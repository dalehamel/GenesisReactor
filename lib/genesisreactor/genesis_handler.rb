class GenesisHandler

  def initialize(genesis)
    @genesis = genesis
    add_routes
    add_handlers
  end

  # Register handler
  def handler(&block)
    @genesis.register_handler(slug, block)
  end

  # Register route
  def route(match, **kwargs, &block)
    @genesis.register_route(slug, __callee__.to_s, match, block, kwargs)
  end

  # Add a routeable verb
  def self.route(name)
    alias_method name, :route
  end

protected

  # abstract
  def add_routes
  end

  # abstract
  def add_handlers
  end

private

  def slug # add to base class
    self.class.name.downcase.gsub('handler','')
  end

end
