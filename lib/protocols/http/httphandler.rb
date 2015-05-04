require 'genesis/handler'
require 'httpprotocol'

# Handle various HTTP verbs
class HttpHandler < Genesis::Handler
  include HttpProtocol

  class << self
    alias_method :get, :register_route
    alias_method :post, :register_route
    alias_method :delete, :register_route
    alias_method :head, :register_route
    alias_method :options, :register_route
    alias_method :patch, :register_route
    alias_method :link, :register_route
    alias_method :unlink, :register_route
  end
end
