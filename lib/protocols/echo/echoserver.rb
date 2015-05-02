require 'eventmachine'

require 'genesis_server'
require 'echoprotocol'

class EchoServer < EM::Connection
  include GenesisServer
  include EchoProtocol
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
