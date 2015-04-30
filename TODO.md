
+ Refactor genesisreactor
+ Finish prototyping HTTPServer
+ Refactor handler, and server modules to work with both echo and HTTP (and thus, hopefully snmp, etc)
 + Maybe allow self.start to accept a block for initializing the server? I like this best so far...
 + Eliminate 'slug' hackery using modules somehow
+ Allow more configuration (which servers to start?)
+ Write core tests for the reactor
 + Registering routes, channels etc work as expected
+ Write tests for echo and http server
 + Tests for their specific routing / subscription things
+ Write agent module and tests (try and do this TDD)
+ Make sure that all modules force some sort of timeout somehow :wave: so that things don't block forever

Things to consider:

+ Allow callbacks wherever we're doing defers?
+ Gemify protocols?
