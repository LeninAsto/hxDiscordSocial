# hxDiscordSocial

`hxDiscordSocial` is a Haxe wrapper for the official Discord Social SDK. It is
designed for hxcpp applications and does not depend on Lime, OpenFL, Flixel or
any particular game engine.

The library currently provides:

- Rich Presence on Windows x64 and Android ARM64 (preview);
- Discord OAuth2 authentication with PKCE;
- access-token restoration and refresh;
- a typed, backend-independent Haxe API;
- main-thread event dispatch through `poll()`;
- fake and unsupported backends for tests and portable builds.

The Android backend uses the same API as Windows. Android host projects still
need to package Discord's AAR and initialize the real game Activity; see the
[Android integration guide](docs/ANDROID.md).

## Requirements

- Haxe 4.3 or newer;
- hxcpp and either a 64-bit MSVC toolchain or Android NDK r27+;
- Discord Social SDK 1.10 or newer;
- a Discord application created in the Developer Portal.

The proprietary SDK is not part of this repository or Haxelib package. Point
the native build to your local SDK copy:

```powershell
$env:DISCORD_SOCIAL_SDK_DIR = 'C:\path\to\discord_social_sdk'
```

## Rich Presence

```haxe
import haxe.Int64;
import hxdiscordsocial.ActivityPlatform;
import hxdiscordsocial.Discord;
import hxdiscordsocial.PresenceBuilder;
import hxdiscordsocial.PresenceButton;

Discord.addListener(event -> trace(event));
Discord.initialize("123456789012345678");

var started = Int64.fromFloat(Date.now().getTime() / 1000);
var presence = new PresenceBuilder()
    .text("Exploring the northern ruins", "Chapter 3")
    .largeAsset("northern_ruins", "The Northern Ruins")
    .smallAsset("ranger", "Ranger")
    .elapsedFrom(started)
    .buttons([new PresenceButton("Game website", "https://example.com")])
    .platforms(ActivityPlatform.Desktop)
    .build();

Discord.setPresence(presence);

// Call from the normal update loop.
Discord.poll();
```

Asset keys are normalized to lowercase by `PresenceBuilder`. Images referenced
by key must be uploaded under **Rich Presence → Art Assets** in the Discord
Developer Portal. HTTPS image URLs are accepted without modification.

## Authentication

Authentication is optional and is not required for local Rich Presence. For a
public-client prototype, enable **Public Client** in the Discord Developer
Portal and start the PKCE flow after initialization:

```haxe
Discord.addListener(event -> switch (event) {
    case Authenticated(token):
        saveSecurely(token.accessToken, token.refreshToken);
    case AuthenticationReady(user):
        trace('Signed in as ${user.displayName} (${user.id})');
    case TokenRefreshRequired:
        Discord.refreshToken(loadRefreshTokenSecurely());
    case Error(operation, error):
        trace('$operation failed: $error');
    default:
});

Discord.authorize();
```

Do not include a Discord client secret in a desktop or mobile executable. A
production confidential-client flow must exchange and refresh tokens on your
own server. Discord authentication identifies the player; it does not provide
cloud storage for application settings.

Methods return `Accepted` when a request passes local validation. Native
completion arrives later as a `DiscordEvent` during `poll()`. Native callbacks
never invoke user Haxe code directly.

## Documentation

- [API and lifecycle](docs/API.md)
- [Authentication](docs/AUTHENTICATION.md)
- [Windows builds and distribution](docs/WINDOWS.md)
- [Android ARM64 integration](docs/ANDROID.md)
- [Security notes](docs/SECURITY.md)
- [Native backend notes](native/windows/README.md)

## Tests

```powershell
haxe tests.hxml

$env:DISCORD_SOCIAL_SDK_DIR = 'C:\path\to\discord_social_sdk'
haxe native-tests.hxml
```

## License

The Haxe wrapper and bridge code use the MIT license. Discord Social SDK files
remain subject to Discord's own terms.
