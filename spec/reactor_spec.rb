RSpec.describe GenesisReactor do

  context 'reactor startup' do
    it 'can start a reactor' do
      reactor = GenesisReactor.new
      expect(reactor.running?).to be false

      expect {
        with_timeout(1) { reactor.start }
      }.to output(/Genesis Reactor initialized/).to_stdout
      expect(reactor.running?).to be false
    end

    it 'can run a server for a protocol' do
      port = 10000

      expect(test_port(port)).to be_nil
      reactor = GenesisReactor.new(
        protocols: {
          EchoProtocol => port
        }
      )
      thr = thread { reactor.start }
      expect(test_port(port)).to be true
      Thread.kill(thr)
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

