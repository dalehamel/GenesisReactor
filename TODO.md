# Next up

+ Implement SNMP trap handler (handle specific trap OID by decoding PDU... maybe make symbolic, maybe not)

+ Write agent module and tests (try and do this TDD)
 + Something to schedule work (schedule DSL command?)
 + Something to make a request (think, provide accesses to snmp get/set)

+ Timeouts
  + specify timeout when instantiating (default to 60? or maybe infinite...)
  + Pass reactor instance to all servers
  + Have all calls to 'defer' done through a wrapper on the reactor instance (so we can inject the timeout)
    + Overriding timeouts somehow by passing argument to defer wrapper

# HTTP

+ Figure out template rendering (paths)
+ Port over transmuter code where relevant

# Refactor
+ Eliminate 'slug' hackery using modules somehow

+ Refactor genesisreactor
+ Refactor genesis server
 + Maybe allow self.start to accept a block for initializing the server? I like this best so far...

+ Allow more configuration (which servers to start?)
+ Write core tests for the reactor
 + Registering routes, channels etc work as expected

+ Write tests for echo and http server
 + Tests for their specific routing / subscription things
+ Make sure that all modules force some sort of timeout somehow :wave: so that things don't block forever
+ Gemify protocols

# Things to consider:

+ Allow callbacks wherever we're doing defers?
+ Dynamic threadpools

## Difference between handler and route:

+ Handlers don't descriminate, they can choose to ignore what they get - but they get everything
+ Routes handle a specific subscription for that protocol
