RSpec.describe Genesis::Reactor do
  let(:port) { 10_000 }
  include SynchronySpec

  context 'reactor can startup' do
    it 'can start a reactor' do
      reactor = Genesis::Reactor.new
      expect(reactor.run).to be true
    end

    it 'can run a server for a protocol' do
      expect(test_port(port)).to be false

      reactor = Genesis::Reactor.new(
        protocols: {
          EchoProtocol => port
        }
      )

      reactor.run
      expect(test_port(port)).to be true
    end
  end

  context 'handlers' do
    it 'can register a route for a protocol' do
      # Simple class registering one route
      class TestRegisterRouteEchoHandler < EchoHandler
        say /test/ do |message|
          "test handler routed #{message}"
        end
      end

      reactor = Genesis::Reactor.new(
        protocols: {
          EchoProtocol => port
        },
        handlers: [TestRegisterRouteEchoHandler]
      )

      reactor.run
      expect(send_to_port('test', port)).to eq 'test handler routed test'
    end

    it 'can register a subscriber for a protocol' do
      # Simple class registering one subscriber
      class TestRegisterSubscriberEchoHandler < EchoHandler
        subscribe 'test' do |message|
          puts "test handler got #{message}"
        end
      end

      reactor = Genesis::Reactor.new(
        protocols: {
          EchoProtocol => port
        },
        handlers: [TestRegisterSubscriberEchoHandler]
      )

      reactor.run
      expect do
        send_to_port('test', port)
        wait_async(1)
      end.to output("test handler got test\n").to_stdout
    end

    it 'can register multiple subscribers for a protocol' do
    end

    it 'can register multiple subscribers for a protocol' do
    end

    it 'can register multiple handlers for a protocol' do
    end
  end
end
