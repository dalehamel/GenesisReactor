require 'eventmachine'

# Abstract base class for all servers
module GenesisServer
  attr_accessor :routes, :channel

  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods
    def start(port, routes)
      @port = port
      @routes = routes
      @channel = EM::Channel.new

      # Allow a custom, non EM, server to be run
      if block_given?
        yield
      else
      # But default to an EM server if nothing else is provided
        fail unless self.validate
        EM.start_server '0.0.0.0', port, self do |conn|
          conn.channel = @channel
          conn.routes = routes[self.slug]
        end
      end
      return @channel
    end

    def slug
      self.name.downcase.gsub('server','')
    end

    # All subclasses must have a name ending with 'Server'
    def validate
      return self.name =~ /^.*Server$/
    end
  end

  # stub
  module InstanceMethods
  end
end
