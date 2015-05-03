require 'genesis_handler'
require 'echoprotocol'

# A test handler to demonstrate functionality and facilitate testing
class EchoHandler < GenesisHandler
  include EchoProtocol

  class << self
    alias_method :say, :register_route
  end
end
