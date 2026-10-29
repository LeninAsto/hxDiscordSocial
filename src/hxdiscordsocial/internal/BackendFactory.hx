package hxdiscordsocial.internal;

import hxdiscordsocial.DiscordBackend;
import hxdiscordsocial.backends.FakeBackend;
import hxdiscordsocial.backends.UnsupportedBackend;
#if (cpp && windows && hxdiscordsocial_native)
import hxdiscordsocial.backends.SocialSdkBackend;
#end

class BackendFactory {
	public static function create():DiscordBackend {
		#if hxdiscordsocial_fake
		return new FakeBackend();
		#elseif (cpp && windows && hxdiscordsocial_native)
		return new SocialSdkBackend();
		#else
		return new UnsupportedBackend();
		#end
	}
}
