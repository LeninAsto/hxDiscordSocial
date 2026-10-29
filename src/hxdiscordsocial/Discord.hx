package hxdiscordsocial;

/** Convenience facade backed by one replaceable default client. */
class Discord {
	static var client:DiscordClient = new DiscordClient();

	public static var state(get, never):DiscordState;
	public static var applicationId(get, never):Null<String>;
	public static var desiredPresence(get, never):Null<Presence>;
	public static var capabilities(get, never):DiscordCapabilities;
	public static var authState(get, never):DiscordAuthState;
	public static var currentUser(get, never):Null<DiscordUser>;
	public static var authToken(get, never):Null<DiscordAuthToken>;

	public static function useClient(value:DiscordClient):Void {
		if (value == null)
			throw "Discord client cannot be null";
		client = value;
	}

	public static inline function initialize(applicationId:String):DiscordResult
		return client.initialize(applicationId);

	public static inline function setPresence(presence:Presence):DiscordResult
		return client.setPresence(presence);

	public static inline function clearPresence():DiscordResult
		return client.clearPresence();

	public static inline function changeApplication(applicationId:String):DiscordResult
		return client.changeApplication(applicationId);

	public static inline function authorize(?scopes:String):DiscordResult return client.authorize(scopes);
	public static inline function restoreToken(accessToken:String):DiscordResult return client.restoreToken(accessToken);
	public static inline function refreshToken(refreshToken:String):DiscordResult return client.refreshToken(refreshToken);
	public static inline function logout():DiscordResult return client.logout();

	public static inline function poll():Void
		client.poll();

	public static inline function shutdown():Void
		client.shutdown();

	public static inline function addListener(listener:DiscordEventListener):Void
		client.addListener(listener);

	public static inline function removeListener(listener:DiscordEventListener):Bool
		return client.removeListener(listener);

	static inline function get_state():DiscordState
		return client.state;

	static inline function get_applicationId():Null<String>
		return client.applicationId;

	static inline function get_desiredPresence():Null<Presence>
		return client.desiredPresence;

	static inline function get_capabilities():DiscordCapabilities
		return client.capabilities;

	static inline function get_authState():DiscordAuthState return client.authState;
	static inline function get_currentUser():Null<DiscordUser> return client.currentUser;
	static inline function get_authToken():Null<DiscordAuthToken> return client.authToken;
}
