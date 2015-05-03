# Implement support for SNMP protocol using pure-ruby snmp.
module SnmpProtocol
  def self.included(base)
    base.extend ClassMethods
  end

  def self.load
    require 'snmpserver'
    SnmpServer
  end

  def self.start_block
    proc { SnmpServer.start_server }
  end

  def self.protocol
    :snmp
  end

  # Methods to be injected into included class
  module ClassMethods
    def protocol
      SnmpProtocol.protocol
    end
  end
end
