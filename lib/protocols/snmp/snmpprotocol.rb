module SnmpProtocol

  def self.included base
    base.extend ClassMethods
  end

  def self.load
    require 'snmpserver'
    return SnmpServer
  end

  def self.start_block
    Proc.new { SnmpServer.start_server }
  end

  def self.protocol
    return :snmp
  end

  module ClassMethods
    def protocol
      return SnmpProtocol.protocol
    end
  end
end
