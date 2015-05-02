module HttpProtocol

  def self.included base
    base.extend ClassMethods
  end

  def self.load
    require 'httpserver'
    return HttpServer
  end

  def self.start_block
    Proc.new { HttpServer.start_server }
  end

  def self.protocol
    return :http
  end

  module ClassMethods
    def protocol
      return HttpProtocol.protocol
    end
  end
end
