require 'eventmachine'
require 'genesis_server'

class EchoServer < EM::Connection
  include GenesisServer
  def receive_data(data)
    @channel << data
    @routes.each do |verb, matchdata|
      if verb == 'say'
        matchdata.each do |pattern, method|
          send_data send(method, data) if data =~ pattern
        end
      end
    end
  end
end
