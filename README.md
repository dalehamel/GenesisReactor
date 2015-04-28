# Genesis Reactor

The genesis reactor is designed to provide access to several servers.

* snmp
* http
* command line
* consoles

It provides two interfaces to these servers:

* Agents (things that poll / schedule tasks to be performed) - generically - event producers
* Handlers (things that respond to a specific event) - generically - event consumers.

Specialized agents and handlers can implement domain specific implementations of these agents/handlers.

A Genesis Daemon is built by including the genesis reactor, and then implementing various agents and handlers (which may, themself, be gems).

# Agent

An agent will register itself with the genesis reactor as an event procuder. This may be something that polls (produces events on a regular interval), or something that produces an event when a specific signal is received.

# Handlers

Handlers will register themselves with the genesis reactor for a specific type of event. When that event is produced, they must consume that event immediately.

The only state that genesis stores is the event queue. This is to ensure that all events may be provided to their handlers.

# Signals

Genesis should respond to sig USR2, which tells it to queue all events received and stop popping the queue. This will allow for clean restarts.

# Death

Genesis may lose events if it is uncleanly killed - USR2 shoud be used to ensure no events are lost.
