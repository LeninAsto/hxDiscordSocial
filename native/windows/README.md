# Windows x64 backend (planned for 0.2.0)

This directory intentionally contains no Discord SDK files.

The implementation will require:

- Discord Social SDK downloaded manually from the Developer Portal.
- `DISCORD_SOCIAL_SDK_DIR` pointing to that local installation.
- MSVC with C++20 support.
- A pure C++ smoke test before the Haxe C ABI/CFFI bridge is enabled.

The bridge must queue native callback results and expose them through
`DiscordBackend.poll()`. It must not call arbitrary Haxe code from a native
callback thread.

Acceptance checks include a missing DLL, Discord closed at startup, late
Discord startup, reconnect, Unicode, invalid assets, clear and orderly shutdown
with work in flight.

