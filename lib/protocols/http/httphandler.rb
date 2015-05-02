require 'genesis_handler'
require 'httpprotocol'

class HttpHandler < GenesisHandler

  include HttpProtocol
  #register_protocol :echo # fixme - abstract out protocol recognition to base handler
  class << self
    alias_method :get, :register_route
    alias_method :post, :register_route
    alias_method :delete, :register_route
    alias_method :head, :register_route
    alias_method :options, :register_route
  end

end
