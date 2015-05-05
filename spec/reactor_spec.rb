RSpec.describe Reactor do
  let(:port) { 10_000 }
  include SynchronySpec

  context 'reactor can startup' do
    it 'can start a reactor' do
      reactor = Reactor.new
      expect(reactor.run).to be true
    end

    it 'can run a server for a protocol' do
      expect(test_port(port)).to be false

      reactor = Reactor.new(
        protocols: {
          Echo::Protocol => port
        }
      )

      reactor.run
      expect(test_port(port)).to be true
    end
  end

  context 'handlers' do
    it 'can register a route for a protocol' do
      # Simple class registering one route
      class TestRegisterRoute < Echo::Handler
        say /test/ do |message|
          "test handler routed #{message}"
        end
      end

      reactor = Reactor.new(
        protocols: {
          Echo::Protocol => port
        },
        handlers: [TestRegisterRoute]
      )

      reactor.run
      expect(send_to_port('test', port)).to eq 'test handler routed test'
    end

    it 'can register a subscriber for a protocol' do
      # Simple class registering one subscriber
      class TestRegisterSubscriber < Echo::Handler
        subscribe 'test' do |message|
          puts "test subscriber got #{message}"
        end
      end

      reactor = Reactor.new(
        protocols: {
          Echo::Protocol => port
        },
        handlers: [TestRegisterSubscriber]
      )

      reactor.run
      expect do
        send_to_port('test', port)
        wait_async(1)
      end.to output("test subscriber got test\n").to_stdout
    end
  end

  context 'agents' do
    it 'can register an agent for a protocol' do
      # Test that an agent can be registered and periodically called
      class TestAgentRegistration < Echo::Agent
        schedule interval: 1 do
          puts 'scheduled'
        end
      end

      reactor = Reactor.new(
        agents: [TestAgentRegistration]
      )
      expect do
        reactor.run
        wait_async(3)
      end.to output(/scheduled\nscheduled\n/).to_stdout
    end

    it 'can register an agent with a subscriber' do
      # Test producitng to a channel from an agent
      class TestAgentProducer < Echo::Agent
        schedule interval: 1 do |channel|
          channel << 'scheduled'
        end
      end

      # Test subscribing to a channel for an agent
      class TestAgentSubscriber < Echo::Handler
        subscribe 'test subscription' do |message|
          puts "test subscriber got #{message}"
        end
      end

      reactor = Reactor.new(
        protocols: { Echo::Protocol => port },
        handlers: [TestAgentSubscriber],
        agents: [TestAgentProducer]
      )
      expect do
        reactor.run
        wait_async(3)
      end.to output(/test subscriber got scheduled\ntest subscriber got scheduled\n/).to_stdout
    end
  end
end
