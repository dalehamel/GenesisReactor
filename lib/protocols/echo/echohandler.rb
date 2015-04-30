require 'genesis_handler'

class EchoHandler < GenesisHandler

  #register_protocol :echo # fixme - abstract out protocol recognition to base handler
  class << self
    alias_method :say, :register_route
  end

end
