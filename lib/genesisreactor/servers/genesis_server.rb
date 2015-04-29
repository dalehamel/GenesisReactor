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
      fail unless self.validate
      @channel = EM::Channel.new
      EM.start_server '127.0.0.1', port, self do |conn|
        conn.channel = @channel
        conn.routes = routes[self.slug]
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
