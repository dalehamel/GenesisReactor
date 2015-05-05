# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require_relative '../lib/genesisreactor.rb'
require 'genesis/protocol/echo'
require 'timeout'
require 'socket'

include Genesis

# Wait for the specified amount of time
# the 'oren' function
def wait_async(time)
  EM::Synchrony.sleep(time)
end

# Helper method to test a port for connectivity
def test_port(port)
  !EventMachine::Synchrony::TCPSocket.new('127.0.0.1', port).nil?
rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
  false
end

# Helper to send messages to a port
# Will wait for a reply until the socket is closed by server
def send_to_port(message, port)
  s = EventMachine::Synchrony::TCPSocket.new('127.0.0.1', port)
  s.write message
  data = ''
  recv = s.read(1)
  while recv
    data += recv
    recv = s.read(1)
  end
  s.close
  data
end

# Helper method to run a block with a timeout
def with_timeout(seconds)
  Timeout.timeout(seconds) do
    yield
  end
rescue Timeout::Error
  false
end

# Include this module in a spec to run all examples within a synchrony block.
# http://blog.carbonfive.com/2011/02/03/raking-and-testing-with-eventmachine/
module SynchronySpec
  def self.append_features(mod)
    mod.class_eval %[
      around(:each) do |example|
        EM.synchrony do
          example.run
          EM.stop
        end
      end
    ]
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
