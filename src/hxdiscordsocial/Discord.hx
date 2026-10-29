package hxdiscordsocial;

/** Convenience facade backed by one replaceable default client. */
class Discord {
	static var client:DiscordClient = new DiscordClient();

	public static var state(get, never):DiscordState;
	public static var applicationId(get, never):Null<String>;
	public static var desiredPresence(get, never):Null<Presence>;

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
}
