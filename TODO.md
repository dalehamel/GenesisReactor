+ Implement SNMP trap handler (handle specific trap OID by decoding PDU... maybe make symbolic, maybe not)

+ Write agent module and tests (try and do this TDD)
 + Something to schedule work (schedule DSL command?)
 + Something to make a request (think, provide accesses to snmp get/set)

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

Things to consider:

+ Allow callbacks wherever we're doing defers?
+ Gemify protocols?

Difference between handler and route:

+ Handlers don't descriminate, they can choose to ignore what they get - but they get everything
+ Routes handle a specific subscription for that protocol
