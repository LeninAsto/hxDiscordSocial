# Changelog

All notable changes to hxDiscordSocial will be documented here.

## Unreleased

- Added OAuth2 authorization with SDK-generated PKCE.
- Added token restoration, refresh, logout and authenticated-user data.
- Added typed authentication states and events dispatched through `poll()`.
- Added `PresenceBuilder` with asset-key normalization.
- Reworked documentation for general Haxe/hxcpp applications.

## 0.2.0 - 2026-10-29

- Added a Windows x64 bridge for Discord Social SDK 1.10+.
- Added asynchronous native event translation through `DiscordClient.poll()`.
- Added SDK discovery through `DISCORD_SOCIAL_SDK_DIR` without vendoring binaries.
- Added pure C++ and Haxe/hxcpp native smoke tests.
- Added automatic runtime DLL copying for native hxcpp executables.
- Expanded Presence to the current activity model: types, clickable URLs,
  assets, buttons, parties, join secrets and supported-platform flags.
- Added explicit backend capability discovery for future Social SDK services.

## 0.1.0 - 2026-10-29

- Added the target-independent `DiscordClient` API and static `Discord` facade.
- Added typed lifecycle states, results, errors, operations and events.
- Added precise `haxe.Int64` presence timestamps.
- Added desired-state retention, duplicate suppression and in-flight coalescing.
- Added injectable fake and safe unsupported backends.
- Added an interpreter-based unit test suite and a basic example.

