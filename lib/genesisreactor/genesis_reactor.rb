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

require 'em-synchrony'

# Main reactor class
class GenesisReactor

  def initialize(**kwargs)
    reset
    @poolsize = kwargs[:threads] || 100 # maximum concurrency - larger = longer boot and shutdown time
    @protocols = kwargs[:protocols] || {}
    register_handlers(kwargs[:handlers] || {})
  end

  # Convenience wrapper to run indefinitely as daemon
  def start
    EM.synchrony do
      run
    end
  end

  # Run the reactor - must be called from EM.run or EM.synchrony
  def run
    if running?
      initialize_protocols
      initialize_threadpool
      initialize_servers
      initialize_agents
      initialize_sighandlers
      return true
    else
      fail 'Must run from within reactor'
    end
  end

  # Check if the reactor is running
  def running?
    return EM.reactor_running?
  end

  # Stop the reactor
  def stop
    EM.stop()
  end

  private

  # Reset / initialize instance variables
  def reset
    @protocols = {}
    @servers = {}
    @routes = {}
    @handlers = {}
    @agents = {}
    @channels = {}
  end

  # Initialize signal handlers (required because of thin)
  def initialize_sighandlers
    trap(:INT)  {"Got interrupt"; EM.stop(); exit }
    trap(:TERM) {"Got term";      EM.stop(); exit }
    trap(:KILL) {"Got kill";      EM.stop(); exit }
  end

  # Initialize servers for each protocol
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
    initialize_handlers
  end

  # Initialize protocols to be handled
  def initialize_protocols
    @protocols.each do |protocol, _|
      server = protocol.load
      @servers[protocol.protocol] = {server: server, port: @protocols[protocol], start: protocol.start_block}
    end
  end

  # Sets the initial size of the threadpool
  def initialize_threadpool
    EM.threadpool_size = @poolsize # move this to initializer so we don't have to allocate while running
  end

  # FIXME actually do this
  def initialize_agents
#    EM.add_periodic_timer(1) do # test
#      EM.defer do
#        puts "Timer fired"
#        sleep 5
#        puts "Done"
#      end
#    end
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
