# Windows x64

Set `DISCORD_SOCIAL_SDK_DIR` before compiling an hxcpp target. The directory
must contain the SDK's `include`, `lib` and `bin` folders. The native bridge
requires MSVC and C++20.

## Runtime file

Copy the release `discord_partner_sdk.dll` beside the executable and name the
copy `discord.dll`. hxDiscordSocial's delay-load hook maps Discord's original
runtime name to that file.

Do not install the DLL system-wide or place it in the Haxe library directory.
Each application should ship the matching runtime with its own build. Do not
publish Discord's SDK files inside this wrapper repository unless the current
SDK terms explicitly permit it.

## Diagnostics

If Presence does not appear:

1. confirm `discord.dll` is beside the actual executable;
2. confirm the build and DLL are x64;
3. run Discord and sign in;
4. check the Application ID;
5. check that uploaded asset keys are lowercase;
6. keep calling `poll()` from the main loop;
7. run Discord and the application at the same privilege level.

Presence buttons are shown to other users and may not appear on the local
user's own card.
