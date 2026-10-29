package hxdiscordsocial;

/** Observable lifecycle of a Discord client. */
enum DiscordState {
	Idle;
	Initializing;
	Ready;
	Degraded;
	Unsupported;
	Closed;
}
