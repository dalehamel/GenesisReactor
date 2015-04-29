require 'eventmachine'
require 'genesis_server'

class EchoServer < EM::Connection
  include GenesisServer
  def receive_data(data)
    @channel << data
    @routes.each do |verb, matchdata|
      case verb
      when 'say'
        matchdata.each do |pattern, blockdata|
          send_data blockdata[:block].call(data) if data =~ pattern
        end
      end
    end
  end
end
