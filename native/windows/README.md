# Windows x64 backend (0.2.0)

This directory intentionally contains no Discord SDK files.

The implementation requires:

- Discord Social SDK downloaded manually from the Developer Portal.
- `DISCORD_SOCIAL_SDK_DIR` pointing to that local installation.
- MSVC with C++20 support.
- A pure C++ smoke test before the Haxe C ABI bridge is enabled.

Build the smoke test from PowerShell:

```powershell
$env:DISCORD_SOCIAL_SDK_DIR = 'C:\path\to\discord_social_sdk'
.\native\windows\smoke\build.ps1
.\native\windows\smoke\build\release\hxdiscordsocial-smoke.exe `
    123456789012345678
```

The executable prints the SDK version, requests a Rich Presence update, waits
for its asynchronous result, clears the presence and exits. It never embeds an
Application ID in the repository.

Build the Haxe/hxcpp integration test from PowerShell:

```powershell
$env:DISCORD_SOCIAL_SDK_DIR = 'C:\path\to\discord_social_sdk'
haxe native-tests.hxml
.\build\native-tests\NativeMain.exe 123456789012345678
```

The bridge queues native callback results and exposes them through
`DiscordBackend.poll()`; it never calls arbitrary Haxe code from a native
callback thread.

Acceptance checks include a missing DLL, Discord closed at startup, late
Discord startup, reconnect, Unicode, invalid assets, clear and orderly shutdown
with work in flight.

