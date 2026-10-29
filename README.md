# hxDiscordSocial

`hxDiscordSocial` is a backend-driven Discord integration for Haxe. Version
0.1.0 establishes the portable API and test infrastructure; it does not yet
ship a native Discord Social SDK backend.

## Current status

- Portable Haxe API: implemented and tested.
- Fake backend: implemented for deterministic tests.
- Unsupported backend: implemented; unsupported targets fail without crashing.
- Windows x64 backend: planned for 0.2.0 and requires a locally downloaded
  Discord Social SDK.
- Android ARM64 backend: planned for 0.3.0 after Windows is stable.

Discord's proprietary SDK, headers and binaries are deliberately not included
in this repository. Future native builds will locate them through
`DISCORD_SOCIAL_SDK_DIR`.

## Basic usage

```haxe
import hxdiscordsocial.Discord;
import hxdiscordsocial.Presence;

Discord.addListener(event -> trace(event));
Discord.initialize("123456789012345678");
Discord.setPresence(new Presence({
    details: "Playing: Blammed",
    state: "Freeplay - Hard",
    largeImage: "plusengine",
    largeText: "FNF Plus Engine"
}));

// Call from the application's main loop.
Discord.poll();

// Call during orderly application shutdown.
Discord.shutdown();
Discord.poll(); // Dispatches the Shutdown event.
```

`initialize`, `setPresence` and `clearPresence` report local acceptance. Native
confirmation is asynchronous and is delivered as a `DiscordEvent` from
`poll()`. Listeners are never invoked directly by a native callback thread.

## Testing

Run from the repository root:

```text
haxe tests.hxml
```

The suite has no third-party test dependency and runs through the Haxe
interpreter.

## Native roadmap

The native backend will use a narrow C ABI/CFFI boundary. Windows x64 comes
first, followed by Android ARM64 through the official AAR and Prefab. See the
platform notes under `native/` for the prerequisites and acceptance checks.

