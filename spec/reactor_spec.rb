require 'genesis_reactor'
require 'echohandler'
require 'timeout'
require 'socket'

RSpec.describe GenesisReactor do

  it 'can start and stop a reactor' do
    reactor = GenesisReactor.new
    expect(reactor.running?).to be false

    expect {
      with_timeout(1) { reactor.start }
    }.to output(/Genesis Reactor initialized/).to_stdout
    expect(reactor.running?).to be false
  end

  it 'runs a server for a protocol' do
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

  def thread
    Thread.new { yield }
  end

  def test_port(port)
    with_timeout(5) do
      sleep 1 until begin
        !TCPSocket.new('127.0.0.1', port ).nil?
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
      return true
    end
  end

  def with_timeout(seconds)
    begin
      Timeout.timeout(seconds) do
        yield
      end
    rescue Timeout::Error
    end
  end

end

