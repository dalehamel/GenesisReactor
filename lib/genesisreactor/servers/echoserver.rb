class EchoServer < EventMachine::Connection
  attr_accessor :routes, :channel

  def self.start(port, routes)
    @channel = EM::Channel.new
    EM.start_server '127.0.0.1', port, self do |conn|
      conn.channel = @channel
      conn.routes = routes['echo'] # FIXME: make this implicit by passing to server superclass initializer and inferring based on subclass type
    end
    return @channel
  end

  def receive_data(data)
    @channel << data
    @routes.each do |pattern, method|
      send_data send(method, data) if data =~ pattern
    end
  end
end
