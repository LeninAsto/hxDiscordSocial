package hxdiscordsocial.internal;

import hxdiscordsocial.DiscordBackend;
import hxdiscordsocial.backends.FakeBackend;
import hxdiscordsocial.backends.UnsupportedBackend;

class BackendFactory {
	public static function create():DiscordBackend {
		#if hxdiscordsocial_fake
		return new FakeBackend();
		#else
		return new UnsupportedBackend();
		#end
	}
}
