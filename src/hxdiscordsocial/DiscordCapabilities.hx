package hxdiscordsocial;

/** Explicit backend capabilities prevent callers from guessing target support. */
class DiscordCapabilities {
	public final richPresence:Bool;
	public final authentication:Bool;
	public final relationships:Bool;
	public final activityInvites:Bool;
	public final lobbies:Bool;
	public final directMessages:Bool;
	public final voice:Bool;
	public final linkedChannels:Bool;

	public function new(richPresence:Bool = false, authentication:Bool = false, relationships:Bool = false, activityInvites:Bool = false,
			lobbies:Bool = false, directMessages:Bool = false, voice:Bool = false, linkedChannels:Bool = false) {
		this.richPresence = richPresence;
		this.authentication = authentication;
		this.relationships = relationships;
		this.activityInvites = activityInvites;
		this.lobbies = lobbies;
		this.directMessages = directMessages;
		this.voice = voice;
		this.linkedChannels = linkedChannels;
	}

	public function supports(feature:DiscordFeature):Bool {
		return switch (feature) {
			case RichPresence: richPresence;
			case Authentication: authentication;
			case Relationships: relationships;
			case ActivityInvites: activityInvites;
			case Lobbies: lobbies;
			case DirectMessages: directMessages;
			case Voice: voice;
			case LinkedChannels: linkedChannels;
			default: false;
		};
	}

	public static inline function none():DiscordCapabilities {
		return new DiscordCapabilities();
	}

	public static inline function presenceOnly():DiscordCapabilities {
		return new DiscordCapabilities(true);
	}

	public static inline function presenceAndAuthentication():DiscordCapabilities {
		return new DiscordCapabilities(true, true);
	}
}
