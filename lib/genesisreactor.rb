require 'find'
require 'eventmachine'

Find.find(File.join(File.dirname(File.dirname(__FILE__)), 'lib')) do |f|
  $LOAD_PATH << f if File.directory? f
end

# FIXME refactor this file to jsut be a small wrapper setting up include path
# Move all the actual code into genesisreactor/genesis_reactor.rb

## We can dynamically adjust the threadpool like below, if we want to.
## It should be possible to make the threadpool elastic very easily, though this may impact performance
#module EventMachine
#  def self.adjust_threadpool
#
#    unless @threadpool.size == @threadpool_size.to_i
#      spawn_threadpool
#    end
#
#end

# Main reactor class
class GenesisReactor

  # FIXME: pass arguments in here
  def initialize(**kwargs)
    reset
    @poolsize = kwargs[:threads] || 10000 # maximum concurrency - larger = longer boot and shutdown time
    @protocols = kwargs[:protocols] || {}
    register_handlers(kwargs[:handlers] || {})
    initialize_protocols
    initialize_handlers
    initialize_threadpool
  end

  def reset
    @protocols = {}
    @servers = {}
    @routes = {}
    @handlers = {}
    @agents = {}
    @channels = {}
  end

  def start
    EM.run do

#      @channels['http'] = HttpServer.start(8080, @routes) { HttpServer.start_server }
#      @channels['snmp'] = SnmpServer.start(1061, @routes) { SnmpServer.start_server }
      initialize_servers
      initialize_agents
      initialize_sighandlers
      puts 'Genesis Reactor initialized'
    end
  end

  private
  def initialize_sighandlers
    trap(:INT)  {"Got interrupt"; EM.stop(); exit }
    trap(:TERM) {"Got term";      EM.stop(); exit }
    trap(:KILL) {"Got kill";      EM.stop(); exit }
  end

  def initialize_servers
    @protocols.each do |protocol, _|
      server = @servers[protocol.protocol]
      @channels[protocol.protocol] = if server[:start].nil?
        server[:server].start(server[:port], @routes[protocol.protocol])
      else
        block = server[:start]
        server[:server].start(server[:port], @routes[protocol.protocol], &block)
      end
    end
  end


  def initialize_protocols
    @protocols.each do |protocol, _|
      server = protocol.load
      @servers[protocol.protocol] = {server: server, port: @protocols[protocol], start: protocol.start_block}
    end
  end

  def initialize_threadpool
    EM.threadpool_size = @poolsize # move this to initializer so we don't have to allocate while running
  end


  # FIXME actually do this
  def initialize_agents
    EM.add_periodic_timer(1) do # test
      EM.defer do
        puts "Timer fired"
        sleep 5
        puts "Done"
      end
    end
  end

  # Set up subscriptions to handlers
  def initialize_handlers
    @handlers.each do |type, handlers|
      if channel = @channels[type]
        handlers.each do |handler|
          channel.subscribe do |message|
            EM.defer do
              handler.call(message)
            end
          end
        end
      end
    end
  end

  # Registers all handlers
  def register_handlers(handlers)
    handlers.each do |handler|
      (handler.routes || {}).each do |match, data|
        register_route(handler.protocol, data[:verb], match, data[:opts], data[:block])
      end

      (handler.handlers || []).each do |data|
        register_handler(handler.protocol, data[:block])
      end
    end
  end

  # Registers a route for a given protocol
  def register_route(protocol, verb, match, args, block)
    @routes[protocol] ||= {}
    @routes[protocol][verb] ||= {}
    @routes[protocol][verb][match] = { block:block, args:args}
  end

  # Registers a handler for a given protocol
  def register_handler(protocol, block)
    @handlers[protocol] ||= []
    @handlers[protocol] << block
  end

  # Registers an agent for a given protocol
  def register_agent(protocol, method)
    @agent[protocol] ||= []
    @agent[protocol] << method
  end

end
