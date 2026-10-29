package hxdiscordsocial.internal;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;

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
		var sdkHeader = Path.join([sdkDir, "include", "discordpp.h"]);
		var importLibrary = Path.join([sdkDir, "lib", "release", "discord_partner_sdk.lib"]);
		var runtimeDir = Path.join([sdkDir, "bin", "release"]);
		for (required in [sdkHeader, importLibrary, Path.join([runtimeDir, "discord_partner_sdk.dll"])]) {
			if (!FileSystem.exists(required)) {
				Context.fatalError('Missing Discord Social SDK file: $required', Context.currentPos());
			}
		}

		var sourceXml = xmlPath(source);
		var includeXml = xmlPath(includeDir);
		var sdkIncludeXml = xmlPath(Path.join([sdkDir, "include"]));
		var importLibraryXml = xmlPath(importLibrary);
		var runtimeDirXml = xmlPath(runtimeDir);
		var xml = '<files id="haxe"><compilerflag value="-I$includeXml" /></files>'
			+ '<files id="__main__"><compilerflag value="-I$includeXml" /></files>'
			+ '<files id="hxdiscordsocial-native">'
			+ '<compilerflag value="-I$includeXml" />'
			+ '<compilerflag value="-I$sdkIncludeXml" />'
			+ '<compilerflag value="/std:c++20" if="windows" unless="mingw" />'
			+ '<compilerflag value="-std=c++20" if="mingw" />'
			+ '<file name="$sourceXml" />'
			+ '</files>'
			+ '<target id="haxe">'
			+ '<files id="hxdiscordsocial-native" />'
			+ '<lib name="$importLibraryXml" if="windows" />'
			+ '</target>'
			+ '<copyFile toolId="exe" name="discord_partner_sdk.dll" from="$runtimeDirXml" overwrite="true" if="windows" />';

		Context.getLocalClass().get().meta.add(":buildXml", [macro $v{xml}], Context.currentPos());
		return Context.getBuildFields();
	}

	static function resolved(path:String):String {
		var macroFile = Path.normalize(FileSystem.fullPath(Context.resolvePath("hxdiscordsocial/internal/NativeBuild.hx")));
		var libraryRoot = Path.directory(Path.directory(Path.directory(Path.directory(macroFile))));
		var result = Path.normalize(Path.join([libraryRoot, path]));
		if (!FileSystem.exists(result)) {
			Context.fatalError('Missing native source: $result', Context.currentPos());
		}
		return result;
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
