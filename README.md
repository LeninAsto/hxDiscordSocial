# hxDiscordSocial

`hxDiscordSocial` is a modern, backend-driven Discord integration for Haxe.
Version 0.2.0 provides the portable API plus a tested Windows x64 backend for
the official Discord Social SDK. The public API does not depend on Lime,
OpenFL, Flixel or a particular engine.

## Current status

- Portable Haxe API: implemented and tested.
- Fake backend: implemented for deterministic tests.
- Unsupported backend: implemented; unsupported targets fail without crashing.
- Windows x64 backend: implemented and tested against Discord Social SDK
  1.10.19337.
- Android ARM64 backend: planned for 0.3.0 after Windows is stable.
- Future services (authentication, relationships, invites, lobbies, messages
  and voice): represented by explicit capability flags and added as isolated
  modules instead of bloating Rich Presence.

Discord's proprietary SDK, headers and binaries are deliberately not included
in this repository. Future native builds will locate them through
`DISCORD_SOCIAL_SDK_DIR`.

## Basic usage

```haxe
import hxdiscordsocial.Discord;
import hxdiscordsocial.ActivityPlatform;
import hxdiscordsocial.Presence;
import hxdiscordsocial.PresenceButton;
import hxdiscordsocial.StatusDisplayType;

Discord.addListener(event -> trace(event));
Discord.initialize("123456789012345678");
Discord.setPresence(new Presence({
    name: "Plus Engine",
    statusDisplayType: StatusDisplayType.Details,
    details: "Playing: Blammed",
    detailsUrl: "https://example.com/songs/blammed",
    state: "Freeplay - Hard",
    largeImage: "plusengine",
    largeText: "FNF Plus Engine",
    buttons: [new PresenceButton("Project page", "https://example.com")],
    supportedPlatforms: ActivityPlatform.Desktop
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

The Presence model covers current Social SDK activity fields: activity and
status-display types, clickable details/state/assets, large and small assets,
invite cover, 64-bit timestamps, two buttons, party metadata/privacy, join
secret and supported-platform flags.

Check a feature before using an optional service:

```haxe
if (Discord.capabilities.supports(RichPresence)) {
    Discord.setPresence(presence);
}
```

## Windows native build

Download the Discord Social SDK separately and point the build at it:

```powershell
$env:DISCORD_SOCIAL_SDK_DIR = 'C:\path\to\discord_social_sdk'
haxe native-tests.hxml
```

The build uses C++20 and copies the required runtime DLL beside the generated
executable. SDK headers, libraries, AARs and DLLs remain outside this Git
repository.

## Testing

Run from the repository root:

```text
haxe tests.hxml
```

The suite has no third-party test dependency and runs through the Haxe
interpreter.

## Roadmap

Android ARM64 follows through the official AAR and Prefab. Once Presence is
stable on both targets, authentication, relationships, invitations, lobbies,
direct messages, voice and linked channels will be implemented as separate
services with capability checks. See `native/` for platform prerequisites and
acceptance checks.

