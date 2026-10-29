# API and lifecycle

## Client styles

`DiscordClient` is an instantiable client. Use it for dependency injection,
isolated tests or explicit ownership. `Discord` is a static facade around one
replaceable default client and is convenient for smaller applications.

Tests can inject `FakeBackend` and complete operations deterministically.

## Lifecycle

1. Register event listeners.
2. Call `initialize(applicationId)` once the main loop exists.
3. Call `poll()` regularly from that loop.
4. Submit Presence or authentication requests.
5. Call `shutdown()` during an orderly exit, then poll once to dispatch the
   local `Shutdown` event.

Application IDs are decimal strings. They never pass through `Float`, which
would lose precision for Discord snowflakes.

`DiscordState` describes the transport lifecycle:

- `Idle`: not initialized;
- `Initializing`: initialization was accepted but not confirmed;
- `Ready`: requests can be submitted;
- `Degraded`: a recoverable backend problem occurred;
- `Unsupported`: no backend exists for this target;
- `Closed`: the client was shut down.

The same client can be initialized again after shutdown.

## Presence model

`Presence` maps to the current Social SDK Activity model. It includes activity
and display types, details/state URLs, artwork, `haxe.Int64` Unix timestamps,
two link buttons, party data, join secrets and supported-platform flags.

Use `PresenceBuilder` in ordinary application code. Construct `Presence`
directly when deserializing a complete configuration.

Good Presence text answers what the player is doing and where they are doing
it. A level, chapter, mode or score is normally more useful than repeating the
application name. Do not publish private lobby names, save-slot names or
user-authored text unless the player opted in.

Use an end timestamp for a countdown and a start timestamp for elapsed time.
Avoid resetting timestamps every frame. The client retains the latest desired
Presence, ignores duplicates and coalesces updates while one is pending.

## Events and capabilities

Events are dispatched only by `poll()`. Listener dispatch uses a snapshot, so a
listener can safely remove itself.

Check optional services at runtime:

```haxe
if (Discord.capabilities.supports(DiscordFeature.Authentication)) {
    Discord.authorize();
}
```

This is more reliable than target checks: a platform may exist while a service
or native backend is unavailable.
