require 'genesis/handler'

module Genesis
  module Echo
    # A test handler to demonstrate functionality and facilitate testing
    class Handler < Genesis::Handler
      include Protocol

      class << self
        alias_method :say, :register_route
      end
    end
  end
end
