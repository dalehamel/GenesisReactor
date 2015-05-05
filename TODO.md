# Next up

+ Implement SNMP trap handler (handle specific trap OID by decoding PDU... maybe make symbolic, maybe not)

+ Timeouts
  + specify timeout when instantiating (default to 60? or maybe infinite...)
  + Pass reactor instance to all servers
  + Have all calls to 'defer' done through a wrapper on the reactor instance (so we can inject the timeout)
    + Overriding timeouts somehow by passing argument to defer wrapper
+ Make sure that all modules force some sort of timeout somehow :wave: so that things don't block forever

# Gemify protocols

+ Make HTTP and SNMP their own gems

## HTTP

+ Figure out template rendering (paths)
+ Port over transmuter code where relevant

+ Write tests for http protocol
 + Tests for their specific routing / subscription things

## SNMP

+ Make trap work for numeric OIDs (maybe symbolic... somehow)
+ Test by generating a trap
+ Make SNMP agent able to send get/set

# Things to consider:

+ Allow callbacks wherever we're doing defers?
+ Dynamic threadpools

## Difference between subscriber and route:

FIXME: update readme with this to clarify

Both routes and subscribers are handlers

+ Subscribers listen for **any** message on a channel, and there can be many subscribers for a protocol.
+ Routes handle messages matching a specific criteria, and there may only be one route per matcher for a protocol.
