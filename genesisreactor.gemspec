Gem::Specification.new do |s|
  s.name        = 'genesisreactor'
  s.version     = '0.0.0'
  s.date        = '2015-04-26'
  s.summary     = 'Event driven infrastructor automation framework'
  s.description = 'A simple hello world gem'
  s.authors     = ['Dale Hamel']
  s.email       = 'dale.hamel@srvthe.net'
  s.files       = ["lib/genesisreactor.rb", 'lib/genesisreactor/servers/httpserver.rb', 'lib/genesisreactor/servers/echoserver.rb']
  s.homepage    =
    'http://rubygems.org/gems/genesisreactor'
  s.license       = 'MIT'
  s.add_runtime_dependency 'eventmachine'
  s.add_runtime_dependency 'eventmachine_httpserver'
  s.add_runtime_dependency 'em-http-request'
  s.add_runtime_dependency 'snmp'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'rspec-eventmachine'
end
