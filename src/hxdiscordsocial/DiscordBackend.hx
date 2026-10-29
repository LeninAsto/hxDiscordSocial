package hxdiscordsocial;

/**
 * Internal transport contract. Backends never invoke Haxe listeners directly;
 * they expose completed work through poll().
 */
interface DiscordBackend {
	public function capabilities():DiscordCapabilities;
	public function initialize(applicationId:String):DiscordResult;
	public function setPresence(presence:Presence):DiscordResult;
	public function clearPresence():DiscordResult;
	public function authorize(scopes:String):DiscordResult;
	public function restoreToken(accessToken:String):DiscordResult;
	public function refreshToken(refreshToken:String):DiscordResult;
	public function logout():DiscordResult;
	public function poll():Array<DiscordEvent>;
	public function shutdown():Void;
}
