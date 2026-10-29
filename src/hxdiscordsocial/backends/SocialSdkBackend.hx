package hxdiscordsocial.backends;

#if (cpp && windows && hxdiscordsocial_native)
import cpp.ConstCharStar;
import hxdiscordsocial.DiscordCapabilities;
import hxdiscordsocial.DiscordBackend;
import hxdiscordsocial.DiscordError;
import hxdiscordsocial.DiscordEvent;
import hxdiscordsocial.DiscordOperation;
import hxdiscordsocial.DiscordResult;
import hxdiscordsocial.Presence;
import hxdiscordsocial.native.SocialSdkNative;

/** Windows x64 backend backed by Discord Social SDK's local RPC transport. */
class SocialSdkBackend implements DiscordBackend {
	static inline final EVENT_READY = 1;
	static inline final EVENT_UPDATED = 2;
	static inline final EVENT_CLEARED = 3;
	static inline final EVENT_DISCONNECTED = 4;
	static inline final EVENT_ERROR = 5;

	static inline final OP_INITIALIZE = 1;
	static inline final OP_SET_PRESENCE = 2;
	static inline final OP_CLEAR_PRESENCE = 3;

	var applicationId:Null<String>;
	var pendingPresence:Null<Presence>;

	public function new() {}

	public function capabilities():DiscordCapabilities {
		return DiscordCapabilities.presenceOnly();
	}

	public function initialize(applicationId:String):DiscordResult {
		if (!SocialSdkNative.initialize(applicationId)) {
			return nativeFailure(false);
		}
		this.applicationId = applicationId;
		return Accepted;
	}

	public function setPresence(presence:Presence):DiscordResult {
		var start:haxe.Int64 = presence.startTimestamp == null ? 0 : presence.startTimestamp;
		var end:haxe.Int64 = presence.endTimestamp == null ? 0 : presence.endTimestamp;
		var buttonOne = presence.buttons.length > 0 ? presence.buttons[0] : null;
		var buttonTwo = presence.buttons.length > 1 ? presence.buttons[1] : null;
		var party = presence.party;
		var accepted = SocialSdkNative.setPresence(value(presence.name), (presence.type : Int),
			presence.statusDisplayType == null ? -1 : (presence.statusDisplayType : Int), value(presence.details), value(presence.detailsUrl),
			value(presence.state), value(presence.stateUrl), value(presence.largeImage), value(presence.largeText), value(presence.largeUrl),
			value(presence.smallImage), value(presence.smallText), value(presence.smallUrl), value(presence.inviteCoverImage), cast start,
			presence.startTimestamp != null, cast end, presence.endTimestamp != null, buttonOne == null ? "" : buttonOne.label,
			buttonOne == null ? "" : buttonOne.url, buttonTwo == null ? "" : buttonTwo.label, buttonTwo == null ? "" : buttonTwo.url,
			party == null ? "" : party.id, party == null ? 0 : party.currentSize, party == null ? 0 : party.maxSize,
			party == null ? 0 : (party.privacy : Int), value(presence.joinSecret),
			presence.supportedPlatforms == null ? 0 : (presence.supportedPlatforms : Int));
		if (!accepted) {
			return nativeFailure(true);
		}
		pendingPresence = presence.copy();
		return Accepted;
	}

	public function clearPresence():DiscordResult {
		if (!SocialSdkNative.clearPresence()) {
			return nativeFailure(true);
		}
		pendingPresence = null;
		return Accepted;
	}

	public function poll():Array<DiscordEvent> {
		SocialSdkNative.runCallbacks();
		var events:Array<DiscordEvent> = [];
		while (true) {
			var eventType = SocialSdkNative.popEvent();
			if (eventType == 0) {
				break;
			}
			switch (eventType) {
				case EVENT_READY:
					events.push(Ready(applicationId == null ? "" : applicationId));
				case EVENT_UPDATED:
					events.push(PresenceUpdated(pendingPresence == null ? new Presence({}) : pendingPresence.copy()));
				case EVENT_CLEARED:
					events.push(PresenceCleared);
				case EVENT_DISCONNECTED:
					events.push(Disconnected(eventError()));
				case EVENT_ERROR:
					events.push(Error(eventOperation(), eventError()));
				default:
					events.push(Error(Poll, new DiscordError(BackendFailure, 'Unknown native event $eventType')));
			}
		}
		return events;
	}

	public function shutdown():Void {
		SocialSdkNative.shutdown();
		applicationId = null;
		pendingPresence = null;
	}

	public static function sdkVersion():String {
		return '${SocialSdkNative.versionMajor()}.${SocialSdkNative.versionMinor()}.${SocialSdkNative.versionPatch()}';
	}

	static function value(input:Null<String>):String {
		return input == null ? "" : input;
	}

	static function nativeString(value:ConstCharStar):String {
		return value == null ? "" : cast value;
	}

	static function nativeFailure(retryable:Bool):DiscordResult {
		var message = nativeString(SocialSdkNative.lastError());
		if (message.length == 0) {
			message = "Discord Social SDK operation failed";
		}
		return Rejected(new DiscordError(BackendFailure, message, retryable));
	}

	static function eventError():DiscordError {
		var message = nativeString(SocialSdkNative.eventMessage());
		if (message.length == 0) {
			message = "Discord Social SDK event failed";
		}
		return new DiscordError(BackendFailure, message, SocialSdkNative.eventRetryable());
	}

	static function eventOperation():DiscordOperation {
		return switch (SocialSdkNative.eventOperation()) {
			case OP_INITIALIZE: Initialize;
			case OP_SET_PRESENCE: SetPresence;
			case OP_CLEAR_PRESENCE: ClearPresence;
			default: Poll;
		};
	}
}
#end
