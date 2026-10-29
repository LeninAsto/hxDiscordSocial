package hxdiscordsocial.backends;

import hxdiscordsocial.DiscordBackend;
import hxdiscordsocial.DiscordError;
import hxdiscordsocial.DiscordResult;
import hxdiscordsocial.DiscordEvent;
import hxdiscordsocial.Presence;

/** Safe fallback used until a validated native backend exists for the target. */
class UnsupportedBackend implements DiscordBackend {
	final target:String;

	public function new(?target:String) {
		this.target = target == null ? detectTarget() : target;
	}

	public function initialize(applicationId:String):DiscordResult {
		return Rejected(unsupportedError());
	}

	public function setPresence(presence:Presence):DiscordResult {
		return Rejected(unsupportedError());
	}

	public function clearPresence():DiscordResult {
		return Rejected(unsupportedError());
	}

	public function poll():Array<DiscordEvent> {
		return [];
	}

	public function shutdown():Void {}

	function unsupportedError():DiscordError {
		return new DiscordError(UnsupportedPlatform, 'Discord is not supported on $target yet');
	}

	static function detectTarget():String {
		#if windows
		return "Windows";
		#elseif android
		return "Android";
		#elseif linux
		return "Linux";
		#elseif mac
		return "macOS";
		#elseif ios
		return "iOS";
		#elseif js
		return "JavaScript";
		#else
		return "this target";
		#end
	}
}
