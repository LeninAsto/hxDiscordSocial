# Android ARM64 backend (planned for 0.3.0)

This directory intentionally contains no proprietary AAR or native library.

Android work starts only after the Windows transport is stable. It will use a
Discord Social SDK 1.10+ AAR, Gradle/Prefab, CMake/JNI and `arm64-v8a`. The
engine Activity must be registered through the SDK's documented Android
initialization hook.

Acceptance checks include 16 KiB pages, Discord installed/absent, signed-in and
signed-out users, background/foreground transitions and Activity recreation.

