package hxdiscordsocial.backends;

#if (cpp && windows && hxdiscordsocial_native)
import cpp.ConstCharStar;
import hxdiscordsocial.DiscordCapabilities;
import hxdiscordsocial.DiscordAuthToken;
import hxdiscordsocial.DiscordUser;
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
	static inline final EVENT_AUTHORIZATION_STARTED = 6;
	static inline final EVENT_AUTHENTICATED = 7;
	static inline final EVENT_AUTH_READY = 8;
	static inline final EVENT_TOKEN_EXPIRING = 9;
	static inline final EVENT_LOGGED_OUT = 10;

	static inline final OP_INITIALIZE = 1;
	static inline final OP_SET_PRESENCE = 2;
	static inline final OP_CLEAR_PRESENCE = 3;
	static inline final OP_AUTHORIZE = 4;
	static inline final OP_RESTORE_TOKEN = 5;
	static inline final OP_REFRESH_TOKEN = 6;
	static inline final OP_LOGOUT = 7;

	var applicationId:Null<String>;
	var pendingPresence:Null<Presence>;

	public function new() {}

	public function capabilities():DiscordCapabilities {
		return DiscordCapabilities.presenceAndAuthentication();
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

	public function authorize(scopes:String):DiscordResult {
		return nativeResult(SocialSdkNative.authorize(value(scopes)), Authorize);
	}

	public function restoreToken(accessToken:String):DiscordResult {
		return nativeResult(SocialSdkNative.restoreToken(value(accessToken)), RestoreToken);
	}

	public function refreshToken(refreshToken:String):DiscordResult {
		return nativeResult(SocialSdkNative.refreshToken(value(refreshToken)), RefreshToken);
	}

	public function logout():DiscordResult {
		return nativeResult(SocialSdkNative.logout(), Logout);
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
				case EVENT_AUTHORIZATION_STARTED:
					events.push(AuthorizationStarted);
				case EVENT_AUTHENTICATED:
					events.push(Authenticated(new DiscordAuthToken(eventData(0), eventData(1), SocialSdkNative.eventNumber(), eventData(2))));
				case EVENT_AUTH_READY:
					events.push(AuthenticationReady(new DiscordUser(eventData(0), eventData(1))));
				case EVENT_TOKEN_EXPIRING:
					events.push(TokenRefreshRequired);
				case EVENT_LOGGED_OUT:
					events.push(LoggedOut);
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

	static function nativeResult(success:Bool, operation:DiscordOperation):DiscordResult {
		return success ? Accepted : nativeFailure(operation == Authorize || operation == RefreshToken);
	}

	static inline function eventData(index:Int):String {
		return nativeString(SocialSdkNative.eventData(index));
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
			case OP_AUTHORIZE: Authorize;
			case OP_RESTORE_TOKEN: RestoreToken;
			case OP_REFRESH_TOKEN: RefreshToken;
			case OP_LOGOUT: Logout;
			default: Poll;
		};
	}
}
#end
