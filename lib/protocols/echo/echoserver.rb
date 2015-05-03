require 'eventmachine'

require 'genesis_server'
require 'echoprotocol'

# Implement a test server to demonstrate functionality and facilitate testing
class EchoServer < EM::Connection
  include GenesisServer
  include EchoProtocol
  def receive_data(data)
    @channel << data
    @handle_routes.each do |verb, matchdata|
      case verb
      when 'say'
        matchdata.each do |pattern, blockdata|
          send_data blockdata[:block].call(data) if data =~ pattern
        end
      end
    end
    close_connection_after_writing
  end
end
