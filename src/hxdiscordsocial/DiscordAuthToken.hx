package hxdiscordsocial;

/** OAuth result. Treat both token strings as secrets and store them securely. */
class DiscordAuthToken {
	public final accessToken:String;
	public final refreshToken:String;
	public final expiresInSeconds:Int;
	public final scopes:String;
	public function new(accessToken:String, refreshToken:String, expiresInSeconds:Int, scopes:String) {
		this.accessToken = accessToken; this.refreshToken = refreshToken;
		this.expiresInSeconds = expiresInSeconds; this.scopes = scopes;
	}
}
