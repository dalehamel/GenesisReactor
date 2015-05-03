RSpec.describe GenesisReactor do

  include SynchronySpec

  context 'reactor startup' do
    it 'can start a reactor' do
      expect {
        reactor = GenesisReactor.new
        reactor.run
      }.to output(/Genesis Reactor initialized/).to_stdout
    end

    it 'can run a server for a protocol' do
      port = 10000

      expect(test_port(port)).to be false
      reactor = GenesisReactor.new(
        protocols: {
          EchoProtocol => port
        }
      )

      reactor.run
      expect(test_port(port)).to be true
    end
  end

  context 'handlers' do

    it 'can register a subscriber for a protocol' do
    end

    it 'can register multiple subscribers for a protocol' do
    end

    it 'can register a route for a protocol' do
    end

    it 'can register multiple subscribers for a protocol' do
    end

    it 'can register multiple handlers for a protocol' do
    end
  end


end

