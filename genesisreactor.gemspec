lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'genesis/version'

Gem::Specification.new do |s|
  s.name        = 'genesisreactor'
  s.version     = Genesis::VERSION
  s.date        = '2015-04-26'
  s.summary     = 'Event driven infrastructor automation framework'
  s.description = 'GenesisReactor provides a protocol agnostic framework for implementing simple pub/sub message production and handling.'
  s.authors     = ['Dale Hamel']
  s.email       = 'dale.hamel@srvthe.net'
  s.files       = Dir['lib/**/*']
  s.homepage    =
    'http://rubygems.org/gems/genesisreactor'
  s.license       = 'MIT'
  s.add_runtime_dependency 'em-synchrony', ['=1.0.4']
  s.add_runtime_dependency 'async_sinatra', ['=1.1.0']
  s.add_runtime_dependency 'thin', ['=1.6.3']
  s.add_runtime_dependency 'snmp', ['=1.2.0']
  s.add_development_dependency 'rspec', ['=3.2.0']
end
