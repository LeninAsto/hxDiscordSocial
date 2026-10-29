package hxdiscordsocial;

/**
 * Opt-in operating-system credential storage.
 *
 * Windows uses Credential Manager. Unsupported targets return false/null and
 * never fall back to plaintext files.
 */
class SecureCredentialStore {
	public static function available():Bool {
		#if (cpp && windows && hxdiscordsocial_native)
		return true;
		#else
		return false;
		#end
	}

	public static function write(key:String, value:String):Bool {
		if (!valid(key) || value == null || value.length == 0) return false;
		#if (cpp && windows && hxdiscordsocial_native)
		return hxdiscordsocial.native.SocialSdkNative.credentialWrite(key, value);
		#else
		return false;
		#end
	}

	public static function read(key:String):Null<String> {
		if (!valid(key)) return null;
		#if (cpp && windows && hxdiscordsocial_native)
		var value:String = cast hxdiscordsocial.native.SocialSdkNative.credentialRead(key);
		return value == null || value.length == 0 ? null : value;
		#else
		return null;
		#end
	}

	public static function remove(key:String):Bool {
		if (!valid(key)) return false;
		#if (cpp && windows && hxdiscordsocial_native)
		return hxdiscordsocial.native.SocialSdkNative.credentialDelete(key);
		#else
		return false;
		#end
	}

	static inline function valid(key:Null<String>):Bool
		return key != null && StringTools.trim(key).length > 0;
}
