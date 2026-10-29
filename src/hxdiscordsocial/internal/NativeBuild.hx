package hxdiscordsocial.internal;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import haxe.zip.Reader;

/** Resolves the local proprietary SDK without adding it to the repository. */
class NativeBuild {
	public static macro function configure():Array<Field> {
		var sdkDir = Sys.getEnv("DISCORD_SOCIAL_SDK_DIR");
		if (sdkDir == null || StringTools.trim(sdkDir).length == 0) {
			Context.fatalError("DISCORD_SOCIAL_SDK_DIR must point to the Discord Social SDK", Context.currentPos());
		}

		sdkDir = Path.normalize(FileSystem.fullPath(sdkDir));
		var source = resolved("native/src/HxDiscordSocialBridge.cpp");
		var includeDir = Path.directory(resolved("native/include/HxDiscordSocialBridge.h"));
		var android = Context.defined("android");
		var sdkHeader:String;
		var importLibrary:String;
		var runtimeSource:Null<String> = null;
		if (android) {
			if (!Context.defined("HXCPP_ARM64"))
				Context.fatalError("hxDiscordSocial currently supports Android arm64-v8a only; build with -D ONLY_ARM64", Context.currentPos());
			var extracted = extractAndroidSdk(sdkDir);
			sdkHeader = Path.join([extracted, "include", "discordpp.h"]);
			importLibrary = Path.join([extracted, "lib", "arm64-v8a", "libdiscord_partner_sdk.so"]);
		} else {
			sdkHeader = Path.join([sdkDir, "include", "discordpp.h"]);
			importLibrary = Path.join([sdkDir, "lib", "release", "discord_partner_sdk.lib"]);
			runtimeSource = Path.join([sdkDir, "bin", "release", "discord_partner_sdk.dll"]);
		}
		for (required in [sdkHeader, importLibrary]) {
			if (!FileSystem.exists(required)) {
				Context.fatalError('Missing Discord Social SDK file: $required', Context.currentPos());
			}
		}
		var runtimeDir = Path.join([libraryRoot(), "build", "native-runtime"]);
		if (!android) {
			if (!FileSystem.exists(runtimeSource)) Context.fatalError('Missing Discord Social SDK file: $runtimeSource', Context.currentPos());
			if (!FileSystem.exists(runtimeDir)) FileSystem.createDirectory(runtimeDir);
			File.copy(runtimeSource, Path.join([runtimeDir, "discord.dll"]));
		}

		var sourceXml = xmlPath(source);
		var includeXml = xmlPath(includeDir);
		var sdkIncludeXml = xmlPath(Path.directory(sdkHeader));
		var importLibraryXml = xmlPath(importLibrary);
		var runtimeDirXml = xmlPath(runtimeDir);
		var xml = '<files id="haxe"><compilerflag value="-I$includeXml" /></files>'
			+ '<files id="__main__"><compilerflag value="-I$includeXml" /></files>'
			+ '<files id="hxdiscordsocial-native">'
			+ '<compilerflag value="-I$includeXml" />'
			+ '<compilerflag value="-I$sdkIncludeXml" />'
			+ '<compilerflag value="/std:c++20" if="windows" unless="mingw" />'
			+ '<compilerflag value="-std=c++20" if="mingw || android" />'
			+ '<file name="$sourceXml" />'
			+ '</files>'
			+ '<target id="haxe">'
			+ '<files id="hxdiscordsocial-native" />'
			+ '<lib name="$importLibraryXml" if="windows || android" />'
			+ '<lib name="delayimp.lib" if="windows" unless="mingw" />'
			+ '<flag value="/DELAYLOAD:discord_partner_sdk.dll" if="windows" unless="mingw" />'
			+ '</target>'
			+ '<copyFile toolId="exe" name="discord.dll" from="$runtimeDirXml" overwrite="true" if="windows" />';

		Context.getLocalClass().get().meta.add(":buildXml", [macro $v{xml}], Context.currentPos());
		return Context.getBuildFields();
	}

	static function extractAndroidSdk(sdkDir:String):String {
		var aar = Path.join([sdkDir, "lib", "release", "discord_partner_sdk.aar"]);
		if (!FileSystem.exists(aar)) Context.fatalError('Missing Discord Social SDK AAR: $aar', Context.currentPos());
		var output = Path.join([libraryRoot(), "build", "android-sdk"]);
		var wanted = [
			"prefab/modules/discord_partner_sdk/include/discordpp.h" => Path.join([output, "include", "discordpp.h"]),
			"prefab/modules/discord_partner_sdk/include/cdiscord.h" => Path.join([output, "include", "cdiscord.h"]),
			"prefab/modules/discord_partner_sdk/libs/android.arm64-v8a/libdiscord_partner_sdk.so" => Path.join([output, "lib", "arm64-v8a", "libdiscord_partner_sdk.so"])
		];
		var input = File.read(aar, true);
		var entries = Reader.readZip(input);
		input.close();
		for (entry in entries) {
			var target = wanted.get(entry.fileName);
			if (target != null) {
				var directory = Path.directory(target);
				if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);
				File.saveBytes(target, Reader.unzip(entry));
				wanted.remove(entry.fileName);
			}
		}
		for (missing in wanted.keys()) Context.fatalError('Discord AAR is missing $missing', Context.currentPos());
		return output;
	}

	static function resolved(path:String):String {
		var result = Path.normalize(Path.join([libraryRoot(), path]));
		if (!FileSystem.exists(result)) {
			Context.fatalError('Missing native source: $result', Context.currentPos());
		}
		return result;
	}

	static function libraryRoot():String {
		var macroFile = Path.normalize(FileSystem.fullPath(Context.resolvePath("hxdiscordsocial/internal/NativeBuild.hx")));
		return Path.directory(Path.directory(Path.directory(Path.directory(macroFile))));
	}

	static function xmlPath(value:String):String {
		value = StringTools.replace(value, "\\", "/");
		value = StringTools.replace(value, "&", "&amp;");
		return StringTools.replace(value, '"', "&quot;");
	}
}
#else
class NativeBuild {}
#end
