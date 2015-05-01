require 'find'
require 'eventmachine'

Find.find(File.join(File.dirname(File.dirname(__FILE__)), 'lib')) do |f|
  $LOAD_PATH << f if File.directory? f
end

# FIXME refactor this file to jsut be a small wrapper
# Move all the actual code into genesisreactor/genesis_reactor.rb

require 'echoserver'
require 'httpserver'

# Main reactor class
class GenesisReactor

  # FIXME: pass arguments in here
  def initialize(**kwargs)
    @poolsize = kwargs[:threads] || 10000 # maximum concurrency - larger = longer boot and shutdown time
    puts @poolsize
    @routes = {}
    @handlers = {}
    @agents = {}
    @channels = {}
  end

  # FIXME: replace type argument with inferred type based on class name
  # FIXME: come up with a strategy for ensuring only one route is published
  def register_route(type, verb, match, args, block)
    @routes[type] ||= {}
    @routes[type][verb] ||= {}
    @routes[type][verb][match] = { block:block, args:args}
  end

  # FIXME: replace type argument with inferred type based on class name
  def register_handler(type, block)
    @handlers[type] ||= []
    @handlers[type] << block
  end

  # FIXME: replace type argument with inferred type based on class name
  def register_agent(type, method)
    @agent[type] ||= []
    @agent[type] << method
  end

  def start
    EM.run do

      EM.threadpool_size = @poolsize
      @channels[EchoServer.slug] = EchoServer.start(10000, @routes)
      @channels['http'] = HttpServer.start(8080, @routes) { HttpServer.start_server }

      initialize_handlers
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
end
