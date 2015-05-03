# Implement a simple protocol to demonstrate
# how to write a protocol, and facilitate testing.
# In keeping with event machine tradition, it's a simple 'echo' protocol.
module EchoProtocol
  def self.included(base)
    base.extend ClassMethods
  end

  def self.load
    require 'echoserver'
    EchoServer
  end

  def self.start_block
  end

  def self.protocol
    :echo
  end

  # Methods to inject into included class
  module ClassMethods
    def protocol
      EchoProtocol.protocol
    end
  end
end
