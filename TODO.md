# Testing

+ Write core tests for the reactor
 + Registering routes, channels etc work as expected
+ Write tests for echo protocol

+ Write tests for http protocol
 + Tests for their specific routing / subscription things

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
+ Make sure that all modules force some sort of timeout somehow :wave: so that things don't block forever

# HTTP

+ Figure out template rendering (paths)
+ Port over transmuter code where relevant

# Refactor

+ Gemify protocols

# Things to consider:

+ Allow callbacks wherever we're doing defers?
+ Dynamic threadpools

## Difference between subscriber and route:

Both routes and subscribers are handlers

+ Subscribers listen for **any** message on a channel, and there can be many subscribers for a protocol.
+ Routes handle messages matching a specific criteria, and there may only be one route per matcher for a protocol.
