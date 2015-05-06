require 'genesis/protocol/snmp'

RSpec.describe Snmp::Protocol do
  let(:port) { 1062 }
  include SynchronySpec

  context 'trap handler' do
    it 'can receieve traps from channel' do

      class SnmpSubscriberTest < Snmp::Handler

        subscribe do |trap|
          puts "got a trap #{trap.trap_oid.join('.')}"
        end
      end

      reactor = Genesis::Reactor.new(
        protocols: {
          Snmp::Protocol => port,
        },
        handlers: [SnmpSubscriberTest],
      )

      expect do
        reactor.run
        Snmp::send_trap(1234, '1.3.6.1.2.3.4', trapport: port)
        wait_async(2)
      end.to output(/got a trap 1.3.6.1.2.3.4/).to_stdout
    end

    it 'can handle a specific trap' do

      class SnmpTrapTest < Snmp::Handler

        trap '1.3.6.1.2.3.4' do |snmp_trap|
          puts "trapped #{snmp_trap.trap_oid.join('.')}"
        end
      end

      reactor = Genesis::Reactor.new(
        protocols: {
          Snmp::Protocol => port,
        },
        handlers: [SnmpTrapTest],
      )

      expect do
        reactor.run
        Snmp::send_trap(1234, '1.3.6.1.2.3.4', trapport: port)
        wait_async(2)
      end.to output(/trapped 1.3.6.1.2.3.4/).to_stdout
    end
  end
end
