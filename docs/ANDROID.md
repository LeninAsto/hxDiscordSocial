# Android ARM64

Android support is available as a preview for `arm64-v8a`. The Haxe API and
event model are identical to Windows, but the host Android project must perform
the platform integration described below. hxDiscordSocial does not commit,
download or redistribute Discord's proprietary AAR.

## Requirements

- Discord Social SDK 1.10 or newer;
- Android NDK r27 or newer;
- an hxcpp/Lime toolchain configured for 16 KB ELF load segments;
- C++20;
- minimum API 23;
- an ARM64 hxcpp build;
- `DISCORD_SOCIAL_SDK_DIR` pointing at the extracted SDK directory.

The directory must contain `lib/release/discord_partner_sdk.aar`. During the
native build hxDiscordSocial extracts the Prefab headers and the ARM64 shared
library into an ignored build directory. A non-ARM64 native compile is rejected
because mixing ABIs produces an APK that installs nicely and crashes less
nicely.

## Gradle

Copy the official AAR into the application module, for example
`app/libs/discord_partner_sdk.aar`, and add:

```kotlin
dependencies {
    implementation(files("libs/discord_partner_sdk.aar"))
    implementation("androidx.browser:browser:1.8.0")
}

android {
    defaultConfig {
        ndk { abiFilters += "arm64-v8a" }
    }
}
```

Packaging the AAR is required even though hxcpp links its `.so` during the
native build: the AAR also contains Discord's Java/Kotlin classes, resources
and manifest metadata.

## Game Activity

Discord must receive the Activity that actually hosts the game. Call this
before the superclass `onCreate`:

```java
import android.os.Bundle;
import com.discord.socialsdk.DiscordSocialSdkInit;

public final class MainActivity extends org.haxe.lime.GameActivity {
    @Override protected void onCreate(Bundle state) {
        DiscordSocialSdkInit.setEngineActivity(this);
        super.onCreate(state);
    }
}
```

Do not pass a launcher, splash or recovery Activity if the game runs in a
different one.

## OAuth redirect

For application ID `123456789012345678`, register this redirect URI in the
Discord Developer Portal:

```text
discord-123456789012345678:/authorize/callback
```

Declare Discord's authentication Activity in the application manifest:

```xml
<activity
    android:name="com.discord.socialsdk.AuthenticationActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="discord-123456789012345678" />
    </intent-filter>
</activity>
```

Enable **Public Client** only for a PKCE public-client flow. Never add a client
secret to the APK.

## Permissions and lifecycle

Rich Presence and account linking require Internet access. If the application
does not implement Social SDK voice, remove the audio, Bluetooth and foreground
voice-service permissions contributed by the AAR during manifest merging.

Keep calling `Discord.poll()` from the Haxe update loop. Re-poll and restore the
last desired Presence after Activity recreation or process reconnection. Store
OAuth tokens with Android Keystore-backed encryption, not plain preferences.

## Release checks

Before shipping:

1. inspect the APK and confirm the application and Discord native libraries are
   present only under `lib/arm64-v8a`;
2. run the Android build-tools 16 KB alignment check;
3. test with Discord installed and absent;
4. test signed in and signed out;
5. test background/foreground and Activity recreation;
6. test authorization and the redirect on a physical ARM64 device.

Compilation proves that the bridge, AAR and Gradle graph agree. It does not
replace the physical-device tests above.

`zipalign -P 16` checks APK entry alignment, not ELF load segments. Also inspect
every packaged `.so` with `llvm-readelf -lW`: each `LOAD` row must use alignment
`0x4000` or greater. Some older hxcpp releases hard-code a 4 KB
`max-page-size`; update or rebuild hxcpp/Lime before shipping if any library
still reports `0x1000`.
