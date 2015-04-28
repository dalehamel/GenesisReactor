require 'find'
require 'eventmachine'

Find.find(File.join(File.dirname(__FILE__), 'genesisreactor')) do |f|
  $LOAD_PATH << f if File.directory? f
end

require 'echoserver'
require 'httpserver'


# Main reactor class
class GenesisReactor
  # FIXME: pass arguments in here
  def initialize
    @poolsize = 10000 # maximum concurrency - larger = longer boot and shutdown time
    @routes = {}
    @handlers = {}
    @agents = {}
  end

  # FIXME: replace type argument with inferred type based on class name
  # FIXME: come up with a strategy for ensuring only one route is published
  def register_route(type, match, method)
    @routes[type] ||= {}
    @routes[type][match] = method
  end

  # FIXME: replace type argument with inferred type based on class name
  def register_handler(type, method)
    @handlers[type] ||= []
    @handlers[type] << method
  end

  # FIXME: replace type argument with inferred type based on class name
  def register_agent(type, method)
    @agent[type] ||= []
    @agent[type] << method
  end

  def start
    EM.run do

      EM.threadpool_size = @poolsize
      @echo_channel = EchoServer.start(10000, @routes)
      # FIXME: for ports
      EM.start_server '127.0.0.1', 10001, HTTPServer, 'foo'

      initialize_handlers
      initialize_agents
      puts 'Genesis Reactor initialized'
    end
  end

  private

  def background (&blocking)
    proc { EM.defer(blocking) }.call
  end

  def initialize_agents
    EM.add_periodic_timer(1) do # test
      background do
        puts "Timer fired"
        sleep 5
        puts "Done"
      end
    end
  end

  # Set up subscriptions to handlers
  def initialize_handlers
    @handlers.each do |type, handlers|
      type_channel_symbol = "@#{type}_channel"
      if instance_variable_defined?(type_channel_symbol)
        type_channel = instance_variable_get(type_channel_symbol)
        handlers.each do |handler|
          type_channel.subscribe do |message|
            background do
              send(handler, message)
            end
          end
        end
      end
    end
  end
end
