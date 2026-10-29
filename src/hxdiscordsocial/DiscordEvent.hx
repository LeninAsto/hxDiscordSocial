package hxdiscordsocial;

/** Events are dispatched only while DiscordClient.poll() is running. */
enum DiscordEvent {
	Ready(applicationId:String);
	PresenceUpdated(presence:Presence);
	PresenceCleared;
	Disconnected(error:DiscordError);
	Error(operation:DiscordOperation, error:DiscordError);
	Shutdown;
}
