module EchoProtocol

  def self.included base
    base.extend ClassMethods
  end

  def self.load
    require 'echoserver'
    return EchoServer
  end

  def self.start_block
    return nil
  end

  def self.protocol
    return :echo
  end

  module ClassMethods
    def protocol
      return EchoProtocol.protocol
    end
  end
end
