package hxdiscordsocial;

class DiscordUser {
	public final id:String;
	public final displayName:String;
	public function new(id:String, displayName:String) {
		this.id = id; this.displayName = displayName;
	}
}
