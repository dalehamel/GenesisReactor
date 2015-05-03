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
    puts "Shutting down"
    EM.stop()
  end

  private

  # Reset / initialize instance variables
  def reset
    @protocols = {}
    @servers = {}
    @routes = {}
    @subscribers = {}
    @agents = {}
    @channels = {}
  end

  # Initialize signal handlers to cleanly shutdown
  def initialize_sighandlers
    trap(:INT)  {puts "Got interrupt"; stop(); exit }
    trap(:TERM) {puts "Got term";      stop(); exit }
    trap(:KILL) {puts "Got kill";      stop(); exit }
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
    initialize_subscribers
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
    EM.threadpool_size = @poolsize
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

  # Set up subscriptions to channels
  def initialize_subscribers
    @subscribers.each do |type, subscribers|
      if channel = @channels[type]
        subscribers.each do |subscriber|
          channel.subscribe do |message|
            EM.defer do
              subscriber.call(message)
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

      (handler.subscribers || []).each do |data|
        register_subscriber(handler.protocol, data[:block])
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
  def register_subscriber(protocol, block)
    @subscribers[protocol] ||= []
    @subscribers[protocol] << block
  end

  # Registers an agent for a given protocol
  def register_agent(protocol, method)
    @agent[protocol] ||= []
    @agent[protocol] << method
  end

end
