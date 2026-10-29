package hxdiscordsocial;

/** Capability names cover the current Discord Social SDK service families. */
enum abstract DiscordFeature(String) from String to String {
	var RichPresence = "rich_presence";
	var Authentication = "authentication";
	var Relationships = "relationships";
	var ActivityInvites = "activity_invites";
	var Lobbies = "lobbies";
	var DirectMessages = "direct_messages";
	var Voice = "voice";
	var LinkedChannels = "linked_channels";
}
