require 'genesis_handler'
require 'echoprotocol'

class EchoHandler < GenesisHandler

  include EchoProtocol

  class << self
    alias_method :say, :register_route
  end

end
