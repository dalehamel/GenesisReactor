# Genesis Reactor

The genesis reactor is designed to implement servers and pub-sub channels for several protocols:

Namely:

* snmp
* http
* command line
* consoles

It provides two interfaces to these servers:

* Agents (things that poll / schedule tasks to be performed or messages to be emitted/ create messages on demand) - generically - event producers
* Handlers (things that respond to a specific event) - generically - event consumers.

Specialized agents and handlers can implement domain specific implementations of these agents/handlers.

A Genesis Daemon is built by including the genesis reactor, and then implementing various agents and handlers (which may, themself, be gems).

# Protocols

Genesis provides a basic interface for developing different types of protocols. These protocols should be gemified, so that they can be extended for a particular application

# Agent

An agent will register itself with the genesis reactor as an event procuder. This may be something that polls (produces events on a regular interval), or something that produces an event when a specific signal is received.

# Handlers

Handlers will register themselves with the genesis reactor for a specific type of event. When that event is produced, they must consume that event immediately.

The only state that genesis stores is the event queue. This is to ensure that all events may be provided to their handlers.

# Routes

Routes are for providing 'syncronous' replies to protocols that expect a reply. The code may not actually run synchronously, but the response is provided syncronously.

This means the connection for anything routed is held open until it receives a response or times out

# Thread pools and blocking

As Genesis is built on event machine, it runs all deferred actions on a shared thread pool. To achieve a near real-time processing synchronously, there must always be more available threads than expected connections.

The maximum concurrency is proportional to the size of this thread pool. All deferred actions must time out eventually, to ensure that their thread is returned to the pool.

If the number of requests exceeds the number of threads, genesis will become backlogged. All deferred actions will be queued and will eventually, but may not be close to realtime

# Death

Genesis may lose events if it is uncleanly killed. If this is a problem, you should run it HA (not yet supported)
